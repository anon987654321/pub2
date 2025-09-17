#!/usr/bin/env ruby
# frozen_string_literal: true

require "net/http"
require "json"
require "logger"
require "optparse"
require "fileutils"

# Repligen - AI Content Generation with Postpro Integration  
# Version: 7.3.0 - Master.json Optimized

module Bootstrap
  def self.dmesg(msg)
    puts "[repligen] #{msg}"
  end

  def self.startup_banner
    ruby_version = RUBY_VERSION
    os = RbConfig::CONFIG["host_os"]
    pwd = Dir.pwd
    dmesg "boot ruby=#{ruby_version} os=#{os} pwd=#{pwd}"
  end

  def self.ensure_sqlite3
    require "sqlite3"
    dmesg "OK sqlite3 gem present"
    true
  rescue LoadError
    dmesg "WARN sqlite3 gem missing, attempting install..."
    begin
      if system("gem install sqlite3 --no-document")
        require "sqlite3"
        dmesg "OK sqlite3 gem installed"
        true
      else
        dmesg "WARN sqlite3 install failed, fallback to JSONL logging"
        false
      end
    rescue => e
      dmesg "WARN sqlite3 unavailable: #{e.message}, using JSONL fallback"
      false
    end
  end

  def self.ensure_token
    return ENV["REPLICATE_API_TOKEN"] if ENV["REPLICATE_API_TOKEN"]

    config_dir = File.expand_path("~/.config/repligen")
    config_file = File.join(config_dir, "config.json")

    if File.exist?(config_file)
      begin
        config = JSON.parse(File.read(config_file))
        token = config["api_token"]
        if token && !token.empty?
          ENV["REPLICATE_API_TOKEN"] = token
          dmesg "OK REPLICATE_API_TOKEN loaded from user config"
          return token
        end
      rescue => e
        dmesg "WARN config file corrupted: #{e.message}"
      end
    end

    if $stdin.tty?
      dmesg "PROMPT Enter REPLICATE_API_TOKEN (from https://replicate.com/account):"
      print "Token: "
      token = gets.chomp.strip
      
      if token && !token.empty?
        FileUtils.mkdir_p(config_dir)
        config = { "api_token" => token }
        File.write(config_file, JSON.pretty_generate(config))
        File.chmod(0600, config_file)
        ENV["REPLICATE_API_TOKEN"] = token
        dmesg "OK token saved to user config (#{config_file})"
        return token
      end
    end

    dmesg "ERROR no REPLICATE_API_TOKEN available"
    nil
  end

  def self.load_master_config
    return {} unless File.exist?("master.json")
    
    begin
      master = JSON.parse(File.read("master.json").gsub(/^.*\/\/.*$/, ""))
      config = master.dig("config", "multimedia", "repligen") || {}
      dmesg "OK loaded defaults from master.json"
      config
    rescue => e
      dmesg "WARN failed to parse master.json: #{e.message}"
      {}
    end
  end

  def self.run
    startup_banner
    sqlite_available = ensure_sqlite3
    token = ensure_token
    config = load_master_config
    
    {
      sqlite_available: sqlite_available,
      token: token,
      config: config
    }
  end
end

class Repligen
  API = 'https://api.replicate.com/v1'
  
  MODELS = {
    imagen3: 'google/imagen-3:bffd1835e5c4ea8d40c18ff2f349a24e7fbdcfe5353135b008bc5795e492e7a6',
    flux: 'black-forest-labs/flux-1.1-pro:8f3e0970b7e77b40f6e940f648098297c4419816f9a6f3503697e9a058b28cfa',
    wan480: 'wan-ai/wan-2.1-i2v-480p:8cedc4c0313c89c8e5a98b3ad5e960a4c60e3b95c0bb7c89a96bbf90c74e967f',
    sdv: 'stability-ai/stable-video-diffusion:3f0457e4619daac51203dedb472816fd4af51f3149fa7a9e0b5ffcf1b3e7bf3f',
    lora: 'replicate/fast-flux-trainer:8b10794665aed907bb98a1a5324cd1d3a8bea0e9b31e65210967fb9c9e2e08ed',
    music: 'meta/musicgen:7be0f12c54a8d85c3f0b1b9c0b0d4e8c0b0d4e8c0b0d4e8c0b0d4e8c0b0d4e8c',
    upscale: 'nightmareai/real-esrgan:f121d640bd286e1fdc67f9799164c1d5be36ff74576ee11c803ae5b665dd46aa'
  }.freeze
  
  COSTS = { imagen3: 0.01, flux: 0.03, wan480: 0.08, sdv: 0.10, music: 0.02, upscale: 0.002, lora: 1.46 }.freeze
  
  CHAINS = {
    quick: %w[imagen3 upscale],
    video: %w[imagen3 wan480],
    full: %w[imagen3 wan480 music],
    creative: %w[flux upscale wan480 music],
    chaos: -> { MODELS.keys.sample(rand(8..15)) }
  }.freeze

  def initialize(token = nil)
    @bootstrap = Bootstrap.run
    @token = token || @bootstrap[:token]
    @logger = Logger.new($stderr, level: ENV["DEBUG"] ? Logger::DEBUG : Logger::WARN)
    @config = @bootstrap[:config]
    
    if @bootstrap[:sqlite_available]
      @db = init_db
      @storage_mode = :sqlite
    else
      @db = nil
      @storage_mode = :jsonl
      @jsonl_file = "repligen_chains.jsonl"
    end
    
    @postpro = File.exist?("postpro.rb")
  end

  def run(cmd = nil, *args)
    return auth_error unless @token
    
    case cmd
    when "generate", "g" then gen_and_offer(args[0] || "futuristic city")
    when "chain", "c" then chain_and_offer(args[0]&.to_sym || default_chain, args[1] || "digital art")
    when "lora", "l" then train_lora(args)
    when "cost" then puts "$%.3f" % cost(args[0]&.to_sym || default_chain)
    when nil then autorun_default
    else interactive
    end
  end

  def default_chain
    (@config["default_chain"] || "quick").to_sym
  end

  def autorun_default
    Bootstrap.dmesg "autorun mode: #{default_chain} chain"
    result = chain_and_offer(default_chain, "digital art")
    
    if result && @postpro && !$stdin.tty?
      Bootstrap.dmesg "launching postpro.rb --from-repligen --auto"
      system("ruby postpro.rb --from-repligen --auto")
    end
    
    result
  end

  private

  def auth_error
    puts "Set REPLICATE_API_TOKEN. Get token at https://replicate.com/account"
    exit 1
  end

  def init_db
    return nil unless @bootstrap[:sqlite_available]
    
    begin
      require "sqlite3"
      SQLite3::Database.new("repligen.db").tap do |db|
        db.execute("CREATE TABLE IF NOT EXISTS chains (id INTEGER PRIMARY KEY, models TEXT, cost REAL, created_at INTEGER)")
      end
    rescue => e
      Bootstrap.dmesg "WARN sqlite3 initialization failed: #{e.message}"
      nil
    end
  end

  def log_chain(models, cost)
    if @storage_mode == :sqlite && @db
      @db.execute("INSERT INTO chains (models, cost, created_at) VALUES (?, ?, ?)", 
                  [models.join(","), cost, Time.now.to_i])
    else
      log_entry = {
        models: models,
        cost: cost,
        timestamp: Time.now.iso8601
      }
      File.open(@jsonl_file, "a") { |f| f.puts JSON.generate(log_entry) }
    end
  end

  def request(endpoint, method = :get, body = nil)
    uri = URI("#{API}/#{endpoint}")
    req = method == :post ? Net::HTTP::Post.new(uri) : Net::HTTP::Get.new(uri)
    req['Authorization'] = "Token #{@token}"
    req['Content-Type'] = 'application/json'
    req.body = body.to_json if body

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 300) { |http| http.request(req) }
    raise "API Error: #{response.code} #{response.body}" unless response.code.to_i.between?(200, 299)
    
    JSON.parse(response.body)
  end

  def predict(model_key, input)
    model, version = MODELS[model_key].split(':')
    
    pred = request('predictions', :post, {
      version: version,
      input: format_input(model_key, input),
      webhook: ENV['WEBHOOK_URL']
    })
    
    wait_for(pred['id'])
  end

  def wait_for(id, timeout = 600)
    start = Time.now
    
    loop do
      pred = request("predictions/#{id}")
      
      case pred['status']
      when 'succeeded' then return pred['output']
      when 'failed' then raise pred['error']
      when 'canceled' then raise 'Canceled'
      end
      
      raise 'Timeout' if Time.now - start > timeout
      
      print '.'
      sleep 2
    end
  end

  def format_input(model, input)
    case model
    when :imagen3, :flux then { prompt: input.is_a?(String) ? input : 'digital art', num_outputs: 1 }
    when :wan480, :sdv then input.start_with?('http') ? { image: input, num_frames: 96 } : { prompt: input }
    when :music then { prompt: 'cinematic', duration: 10 }
    when :upscale then { image: input, scale: 2 }
    when :lora then { input_images: input.is_a?(Array) ? input.join(',') : input, trigger_word: 'subject' }
    else { input: input }
    end
  end

  def chain(type, prompt)
    models = chain_for(type)
    puts "Running #{models.length}-step chain..."
    
    output = prompt
    cost = 0.0
    
    models.each_with_index do |model, i|
      puts "Step #{i + 1}: #{model}"
      output = predict(model.to_sym, output)
      cost += COSTS[model.to_sym]
    end
    
    log_chain(models, cost)
    
    puts "\nComplete! Cost: $%.3f" % cost
    
    save_output(output, type, prompt) if output.is_a?(String) && output.start_with?("http")
    output
  end

  def save_output(url, type, prompt)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    
    return unless response.code == '200'
    
    filename = "#{sanitize(prompt)}_generated_#{type}_#{Time.now.strftime('%Y%m%d%H%M%S')}.jpg"
    File.write(filename, response.body)
    puts "Saved: #{filename}"
    File.utime(Time.now, Time.now, filename)
  rescue StandardError => e
    puts "Could not save output: #{e.message}"
  end

  def sanitize(prompt)
    prompt.to_s.gsub(/[^\w\-_]/, '_').slice(0, 20)
  end

  def chain_for(type)
    CHAINS[type].respond_to?(:call) ? CHAINS[type].call : CHAINS[type]
  end

  def generate(prompt)
    chain(:quick, prompt)
  end

  def gen_and_offer(prompt)
    result = generate(prompt)
    offer_postpro if @postpro && result
    result
  end

  def chain_and_offer(type, prompt)
    result = chain(type, prompt)
    offer_postpro if @postpro && result
    result
  end

  def train_lora(urls)
    raise 'Provide image URLs' if urls.empty?
    
    puts 'Training LoRA...'
    output = predict(:lora, urls)
    puts "Model: #{output}"
    output
  end

  def cost(chain_type)
    chain_for(chain_type).sum { |m| COSTS[m.to_sym] }
  end

  def offer_postpro
    if $stdin.tty?
      puts "\nPostpro.rb detected! Want to apply cinematic processing?"
      print "Launch postpro? (Y/n): "
      
      response = gets.chomp.downcase
      if response.empty? || response.start_with?("y")
        puts "Launching postpro.rb with masterpiece presets..."
        system("ruby postpro.rb --from-repligen")
      else
        puts "Run 'ruby postpro.rb' later to process generated images"
      end
    else
      Bootstrap.dmesg "non-interactive mode, skipping postpro offer"
    end
  end

  def interactive
    puts "\nRepligen Interactive Mode"
    puts "Commands: (g)enerate, (c)hain, (l)ora, cost, quit"
    puts "Postpro.rb integration: Active" if @postpro
    
    loop do
      print "> "
      input = gets&.chomp&.split || []
      cmd = input.shift
      
      handle_cmd(cmd, input)
    rescue => e
      puts "Error: #{e.message}"
      @logger.debug e.backtrace.join("\n")
    end
  end

  def handle_cmd(cmd, args)
    case cmd
    when 'g', 'generate' then gen_and_offer(args.empty? ? 'digital art' : args.join(' '))
    when 'c', 'chain' then chain_and_offer(args[0]&.to_sym || :quick, args[1..-1]&.join(' ') || 'art')
    when 'l', 'lora' then train_lora(args)
    when 'cost' then puts "$%.3f" % cost(args[0]&.to_sym || :quick)
    when 'postpro', 'p'
      @postpro ? system('ruby postpro.rb') : puts("postpro.rb not found")
    when 'q', 'quit' then exit
    else puts "Unknown: #{cmd}"
    end
  end
end

if __FILE__ == $0
  OptionParser.new do |opts|
    opts.banner = 'Usage: repligen.rb [command] [args]'
    opts.on('-t TOKEN', '--token TOKEN', 'API token') { |t| ENV['REPLICATE_API_TOKEN'] = t }
    opts.on('-d', '--debug', 'Debug mode') { ENV['DEBUG'] = '1' }
    opts.on('-h', '--help', 'Show help') { puts opts; exit }
  end.parse!
  
  begin
    Repligen.new.run(ARGV[0], *ARGV[1..-1])
  rescue Interrupt
    puts "\nBye"
  rescue => e
    puts "Fatal: #{e.message}"
    puts e.backtrace if ENV['DEBUG']
    exit 1
  end
end
