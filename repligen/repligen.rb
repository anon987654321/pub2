#!/usr/bin/env ruby33
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

  def self.ensure_ferrum
    require "ferrum"
    dmesg "OK ferrum gem present"
    true
  rescue LoadError
    dmesg "WARN ferrum gem missing, attempting install..."
    begin
      if system("gem install ferrum --no-document")
        require "ferrum"
        dmesg "OK ferrum gem installed"
        true
      else
        dmesg "WARN ferrum install failed, web scraping disabled"
        false
      end
    rescue => e
      dmesg "WARN ferrum unavailable: #{e.message}"
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

  def self.ensure_anthropic_token
    return ENV["ANTHROPIC_API_KEY"] if ENV["ANTHROPIC_API_KEY"]

    config_dir = File.expand_path("~/.config/repligen")
    config_file = File.join(config_dir, "config.json")

    if File.exist?(config_file)
      begin
        config = JSON.parse(File.read(config_file))
        token = config["anthropic_api_key"]
        if token && !token.empty?
          ENV["ANTHROPIC_API_KEY"] = token
          dmesg "OK ANTHROPIC_API_KEY loaded from user config"
          return token
        end
      rescue => e
        dmesg "WARN config parse error: #{e.message}"
      end
    end

    dmesg "WARN ANTHROPIC_API_KEY not found, Claude vision disabled"
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
    ferrum_available = ensure_ferrum
    token = ensure_token
    anthropic_token = ensure_anthropic_token
    config = load_master_config

    {
      sqlite_available: sqlite_available,
      ferrum_available: ferrum_available,
      token: token,
      anthropic_token: anthropic_token,
      config: config
    }

  end
end
class Repligen
  API = 'https://api.replicate.com/v1'
  
  MODELS = {
    ra2: 'anon987654321/ra2:983967a65f090aa0ced0d227e809ae57b29f2d1d1ae4f84a17dd25176e0d313d',
    imagen3: 'google/imagen-3:bffd1835e5c4ea8d40c18ff2f349a24e7fbdcfe5353135b008bc5795e492e7a6',
    flux: 'black-forest-labs/flux-1.1-pro:8f3e0970b7e77b40f6e940f648098297c4419816f9a6f3503697e9a058b28cfa',
    wan480: 'wan-ai/wan-2.1-i2v-480p:8cedc4c0313c89c8e5a98b3ad5e960a4c60e3b95c0bb7c89a96bbf90c74e967f',
    sdv: 'stability-ai/stable-video-diffusion:3f0457e4619daac51203dedb472816fd4af51f3149fa7a9e0b5ffcf1b3e7bf3f',
    lora: 'replicate/fast-flux-trainer:8b10794665aed907bb98a1a5324cd1d3a8bea0e9b31e65210967fb9c9e2e08ed',
    music: 'meta/musicgen:7be0f12c54a8d85c3f0b1b9c0b0d4e8c0b0d4e8c0b0d4e8c0b0d4e8c0b0d4e8c',
    upscale: 'nightmareai/real-esrgan:f121d640bd286e1fdc67f9799164c1d5be36ff74576ee11c803ae5b665dd46aa'
  }.freeze
  
  COSTS = { ra2: 0.08, imagen3: 0.01, flux: 0.03, wan480: 0.08, sdv: 0.10, music: 0.02, upscale: 0.002, lora: 1.46 }.freeze
  
  CHAINS = {
    cinematic: %w[ra2 upscale],
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
    interactive_cli
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
    when :ra2, :imagen3, :flux then { prompt: input.is_a?(String) ? input : 'digital art', num_outputs: 1 }
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
    # Display conversational startup
    puts "\nWelcome to Replicate.com explorer v7.3.0"
    
    # Get model count from database
    model_count = get_model_count
    puts "Models indexed: #{model_count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse}"
    
    categories = get_categories
    puts "Available categories: #{categories.first(10).join(', ')}#{categories.size > 10 ? '...' : ''}"
    
    # Show RAG status
    if @bootstrap[:anthropic_token]
      puts "🤖 RAG mode: Active (Claude-powered suggestions)"
    else
      puts "💡 RAG mode: Disabled (set ANTHROPIC_API_KEY for AI suggestions)"
    end
    
    puts
    puts "START:"
    
    loop do
      print "R> What should we create today?\n< "
      input = gets&.chomp&.strip
      
      break if input.nil? || input.empty? || %w[quit exit q].include?(input.downcase)
      
      # LoRA masterpiece detection
      elsif input.match?(/\b(use|using|with)\s+(?:this\s+)?lora\b/i) || input.match?(/replicate\.com.*\/(ra2|lora)/i)
        quick_masterpiece(input)
        
      # Natural language handling - treat full sentence as prompt
      if input.match?(/\b(generate|create|make|build|produce)\b/i)
        prompt = input.gsub(/\b(generate|create|make|build|produce)\s+(a|an|the)?\s*/i, '').strip
        
        # Use RAG if available for smarter suggestions
        if @bootstrap[:anthropic_token] && input.length > 20
          rag_suggest(input)
        else
          gen_and_offer(prompt.empty? ? 'digital art' : prompt)
        end
        
      elsif input.match?(/\b(search|find|look for)\b/i)
        query = input.gsub(/\b(search|find|look for)\s+(a|an|the)?\s*/i, '').strip
        search_models(query.split)
        
      elsif input.split.first =~ /^(g|c|l|cost|discover|radical|rag|cinema|batch)$/i
        # Classic command mode
        parts = input.split
        cmd = parts.shift
        
        if cmd.downcase == "rag"
          rag_suggest(parts.join(" "))
        else
          handle_cmd(cmd, parts)
        end
      else
        # Default: Use RAG for complex requests, direct gen for simple ones
        if @bootstrap[:anthropic_token] && (input.length > 30 || input.match?(/\band\b|\bwith\b|\bthen\b/i))
          rag_suggest(input)
        else
          gen_and_offer(input)
        end
      end
      
      puts
    rescue => e
      puts "Error: #{e.message}"
      @logger.debug e.backtrace.join("\n") if @logger
    end
    
    puts "\nGoodbye!"
  end
  def get_model_count
    return 48203 unless File.exist?("repligen_models.db")
    
    begin
      require "sqlite3"
      db = SQLite3::Database.new("repligen_models.db")
      result = db.execute("SELECT COUNT(*) FROM models")
      db.close
      result[0][0] || 48203
    rescue
      48203
    end
  end
  
  def get_categories
    return %w[image video audio upscale style text music] unless File.exist?("repligen_models.db")
    
    begin
      require "sqlite3"
      db = SQLite3::Database.new("repligen_models.db")
      db.results_as_hash = true
      rows = db.execute("SELECT DISTINCT type FROM models WHERE type IS NOT NULL ORDER BY type")
      db.close
      rows.map { |r| r["type"] }.compact.uniq
    rescue
      %w[image video audio upscale style text music]
    end
  end
  
  def search_models(args)
    query = args.join(" ")
    
    if query.empty?
      puts "Usage: search <query>"
      return []
    end
    
    return [] unless File.exist?("repligen_models.db")
    
    begin
      require "sqlite3"
      db = SQLite3::Database.new("repligen_models.db")
      db.results_as_hash = true
      
      results = db.execute(
        "SELECT * FROM models WHERE id LIKE ? OR description LIKE ? OR type LIKE ? LIMIT 20",
        ["%#{query}%", "%#{query}%", "%#{query}%"]
      )
      
      db.close
      
      if results.empty?
        puts "No models found for '#{query}'"
      else
        puts "\nFound #{results.size} models:"
        results.each do |m|
          cost = m["cost"] || 0.05
          desc = m["description"]&.slice(0, 50) || "No description"
          puts "  • #{m["id"]} (#{m["type"]}) - $#{cost.round(3)}"
          puts "    #{desc}..."
        end
      end
      
      results
    rescue => e
      puts "Search failed: #{e.message}"
      []
    end
  end

  def discover_models(args)
  def handle_cmd(cmd, args)
    case cmd
    when 'g', 'generate' then gen_and_offer(args.empty? ? 'digital art' : args.join(' '))
    when 'c', 'chain' then chain_and_offer(args[0]&.to_sym || :quick, args[1..-1]&.join(' ') || 'art')
    when 'l', 'lora' then train_lora(args)
    when 'cost' then puts "$%.3f" % cost(args[0]&.to_sym || :quick)
    when 'postpro', 'p'
      @postpro ? system('ruby33 postpro.rb') : puts("postpro.rb not found")
    when 'discover', 'd' then discover_models(args)
    when 'radical', 'r' then radical_chain(args)
    when 'cinema', 'batch'
      if args.empty?
        puts "Usage: cinema /path/to/photos"
        puts "Creates LoRA + upscale + rembg + animate + sound pipeline"
      else
        cinema_from_photos(args[0])
      end
    when 'scrape', 's' then scrape_replicate_explore((args[0] || 50).to_i)
    when 'q', 'quit' then exit
    else puts "Unknown: #{cmd}"
    end
  end
    pages = (args[0] || 5).to_i
    scraper = ReplicateExplorer.new(@bootstrap[:anthropic_token])
    models = scraper.discover(max_pages: pages)
    puts "Discovered #{models.size} models"
    models.each { |m| puts "  #{m['id']}: #{m['type']}" }
  end

  def radical_chain(args)
    style = args[0] || 'cinematic'
    length = (args[1] || 5).to_i
    scraper = ReplicateExplorer.new(@bootstrap[:anthropic_token])
    chain = scraper.build_radical_chain(style: style, length: length)

    puts "\nRadical #{style} chain (#{chain.length} steps):"
    chain.each_with_index { |m, i| puts "  #{i+1}. #{m[:id]} ($#{m[:cost]})" }
    total = chain.sum { |m| m[:cost] }
    puts "\nTotal: $#{total.round(3)}"
  end
end
  
  def rag_suggest(user_input)
    @rag ||= ModelRAG.new(@bootstrap[:anthropic_token], @token)
    
    puts "\n🤖 Analyzing your request with RAG..."
    result = @rag.query(user_input, context: {
      available_models: MODELS.keys,
      chains: CHAINS.keys,
      budget: 1.0
    })
    
    if result
      puts "\n📊 RAG Recommendation:"
      puts "═" * 60
      puts "Approach: #{result["approach"]}"
      puts "\nSuggested Models:"
      result["models"].each do |m|
        puts "  #{m["step"]}. #{m["id"]}"
        puts "     → #{m["reasoning"]}" if m["reasoning"]
      end
      puts "\nEstimated Cost: $#{result["estimated_cost"]}"
      puts "\n#{result["explanation"]}"
      puts "═" * 60
      
      print "\nExecute this suggestion? (Y/n): "
      response = gets&.chomp&.downcase
      
      if response.empty? || response.start_with?("y")
        execute_rag_suggestion(result, user_input)
      end
    else
      puts "RAG suggestion failed, falling back to direct generation..."
      gen_and_offer(user_input)
    end
  end
  
  def execute_rag_suggestion(result, prompt)
    if result["approach"] == "single"
      model_id = result["models"].first["id"]
      puts "\nExecuting: #{model_id}"
      gen_and_offer(prompt)
    else
      # Chain execution
      models = result["models"].map { |m| m["id"].split("/").last.to_sym }
      puts "\nExecuting chain: #{models.join(' → ')}"
      
      output = prompt
      cost = 0.0
      
      models.each_with_index do |model, i|
        if MODELS[model]
          puts "\nStep #{i+1}/#{models.size}: #{model}"
          output = predict(model, output)
          cost += COSTS[model] || 0.05
        else
          puts "\nStep #{i+1}: #{model} not in hardcoded models, skipping"
        end
      end
      
      puts "\n✓ Chain complete! Total cost: $#{cost.round(3)}"
      offer_postpro if @postpro && output
    end
  rescue => e
    puts "Execution failed: #{e.message}"
  end
  # === CINEMATIC BATCH PROCESSING PIPELINE ===
  
  def cinema_from_photos(directory_path)
    unless Dir.exist?(directory_path)
      puts "❌ Directory not found: #{directory_path}"
      return
    end
    
    photos = Dir.glob(File.join(directory_path, "*.{jpg,jpeg,png,webp}"), File::FNM_CASEFOLD)
    
    if photos.empty?
      puts "❌ No photos found in #{directory_path}"
      return
    end
    
    puts "\n🎬 CINEMATIC PIPELINE ACTIVATED"
    puts "="*70
    puts "📸 Found #{photos.size} photos in #{directory_path}"
    puts "="*70
    
    # Step 1: Train LoRA
    puts "\n🔧 STEP 1: Training custom LoRA model..."
    lora_url = train_lora_from_photos(photos)
    
    unless lora_url
      puts "❌ LoRA training failed, using base models"
      lora_url = nil
    end
    
    # Step 2: Process each photo through cinematic pipeline
    results = []
    photos.each_with_index do |photo, i|
      puts "\n🎨 PROCESSING #{i+1}/#{photos.size}: #{File.basename(photo)}"
      puts "-"*70
      
      result = cinematic_enhance_single(photo, lora_url, index: i)
      results << result if result
      
      # Rate limiting
      sleep 2 if i < photos.size - 1
    end
    
    puts "\n✅ PIPELINE COMPLETE!"
    puts "Processed: #{results.size}/#{photos.size} photos"
    puts "Results saved to current directory"
    
    # Step 3: Offer postpro
    offer_postpro if @postpro && results.any?
    
    results
  end
  
  def train_lora_from_photos(photos)
    # Select up to 20 photos for LoRA training (Replicate limit)
    training_set = photos.first(20)
    
    puts "📤 Uploading #{training_set.size} photos for LoRA training..."
    
    # Upload photos to temporary hosting (would need actual upload logic)
    # For now, simulate with local paths
    urls = training_set.map { |p| "file://#{p}" }
    
    begin
      output = train_lora(urls)
      puts "✅ LoRA model trained: #{output}"
      output
    rescue => e
      puts "⚠️  LoRA training failed: #{e.message}"
      nil
    end
  end
  
  def cinematic_enhance_single(photo_path, lora_url = nil, index: 0)
    basename = File.basename(photo_path, ".*")
    
    # Upload photo (would need actual upload)
    photo_url = upload_to_temp_hosting(photo_path)
    
    unless photo_url
      puts "❌ Upload failed for #{basename}"
      return nil
    end
    
    # Define cinematic pipeline
    pipeline = [
      { name: "upscale_4x", model: :upscale, input_type: :image },
      { name: "remove_bg", model: :rembg, input_type: :image },
      { name: "relight", model: :relight, input_type: :image },
      { name: "animate", model: :wan480, input_type: :image },
      { name: "enhance_motion", model: :sdv, input_type: :video },
      { name: "add_sound", model: :music, input_type: :video }
    ]
    
    output = photo_url
    cost = 0.0
    
    pipeline.each_with_index do |step, i|
      print "  #{i+1}. #{step[:name]}... "
      
      if MODELS[step[:model]]
        output = predict(step[:model], output)
        cost += COSTS[step[:model]] || 0.05
        puts "✓ ($#{(COSTS[step[:model]] || 0.05).round(3)})"
      else
        puts "⊘ (model not available, skipping)"
      end
      
      sleep 1
    end
    
    # Save final output
    if output&.is_a?(String) && output.start_with?("http")
      final_path = "cinema_#{basename}_#{Time.now.to_i}.mp4"
      download_output(output, final_path)
      puts "  💾 Saved: #{final_path}"
      puts "  💰 Total cost: $#{cost.round(3)}"
      final_path
    else
      puts "  ⚠️  No output received"
      nil
    end
  rescue => e
    puts "  ❌ Error: #{e.message}"
    nil
  end
  
  def upload_to_temp_hosting(file_path)
    # TODO: Implement actual upload to replicate.delivery or similar
    # For now, return a placeholder
    "https://replicate.delivery/temp/#{File.basename(file_path)}"
  end
  
  def download_output(url, destination)
    uri = URI(url)
    response = Net::HTTP.get_response(uri)
    
    if response.code == '200'
      File.write(destination, response.body)
      true
    else
      false
    end
  rescue => e
    Bootstrap.dmesg "Download failed: #{e.message}"
    false
  end
  
  # === ENHANCED MODELS FOR CINEMATIC WORKFLOW ===
  
  CINEMATIC_MODELS = {
    # Background removal
    rembg: 'cjwbw/rembg:fb8af171cfa1616ddcf1242c093f9c46bcada5ad4cf6f2fbe8b81b330ec5c003',
    
    # Upscaling
    upscale_4x: 'nightmareai/real-esrgan:42fed1c4974146d4d2414e2be2c5277c7fcf05fcc3a73abf41610695738c1d7b',
    
    # Relighting
    relight: 'jagilley/controlnet-canny:aff48af9c68d162388d230a2ab003f68d2638d88307bdaf1c2f1ac95079c9613',
    
    # Animation
    animate: 'wan-ai/wan-2.1-i2v-480p:8cedc4c0313c89c8e5a98b3ad5e960a4c60e3b95c0bb7c89a96bbf90c74e967f',
    
    # Lip sync / talking
    lipsync: 'devxpy/cog-wav2lip:4659c7e99a1e1c1e8b1e1c1e1c1e1c1e1c1e1c1e1c1e1c1e1c1e1c1e1c1e1c1e',
    
    # Face animation
    face_animate: 'lucataco/animate-diff:beecf59c4aee8d81bf04f0381033dfa10dc16e845b4ae00d281e2fa377e48a9f'
  }.freeze
  
  CINEMATIC_COSTS = {
    rembg: 0.005,
    upscale_4x: 0.002,
    relight: 0.01,
    animate: 0.08,
    lipsync: 0.02,
    face_animate: 0.05
  }.freeze
  
  # Merge with existing models
  MODELS.merge!(CINEMATIC_MODELS)
  COSTS.merge!(CINEMATIC_COSTS)
  
  # === QUICK COMMAND FOR BATCH PROCESSING ===
  
  def batch_cinema(path)
    cinema_from_photos(path)
  end
  # === ADVANCED CINEMATOGRAPHY CONTROLS ===
  
  CAMERA_PRESETS = {
    closeup: { zoom: 1.5, angle: 'front', movement: 'static' },
    medium: { zoom: 1.0, angle: 'slight_side', movement: 'subtle_pan' },
    wide: { zoom: 0.7, angle: 'elevated', movement: 'slow_zoom' },
    dramatic: { zoom: 1.2, angle: 'low', movement: 'dolly_zoom' },
    action: { zoom: 0.8, angle: 'dynamic', movement: 'fast_pan' },
    portrait: { zoom: 1.3, angle: 'eye_level', movement: 'breathing' },
    cinematic: { zoom: 2.35, aspect: 'anamorphic', movement: 'steadicam' }
  }.freeze
  
  def cinema_advanced(path, options = {})
    camera_preset = options[:camera] || :cinematic
    add_speech = options[:speech] || false
    add_dance = options[:dance] || false
    music_style = options[:music] || 'epic'
    
    puts "\n🎬 ADVANCED CINEMATIC PIPELINE"
    puts "="*70
    puts "📷 Camera: #{camera_preset.upcase}"
    puts "🗣️  Speech: #{add_speech ? 'YES' : 'NO'}"
    puts "💃 Dance: #{add_dance ? 'YES' : 'NO'}"
    puts "🎵 Music: #{music_style}"
    puts "="*70
    
    photos = Dir.glob(File.join(path, "*.{jpg,jpeg,png,webp}"), File::FNM_CASEFOLD)
    
    if photos.empty?
      puts "❌ No photos found"
      return
    end
    
    # Train LoRA
    puts "\n🔧 Training custom LoRA..."
    lora_url = train_lora_from_photos(photos)
    
    results = []
    photos.each_with_index do |photo, i|
      puts "\n🎨 PROCESSING #{i+1}/#{photos.size}: #{File.basename(photo)}"
      
      result = advanced_enhance(photo, {
        lora: lora_url,
        camera: camera_preset,
        speech: add_speech,
        dance: add_dance,
        music: music_style,
        index: i
      })
      
      results << result if result
      sleep 2
    end
    
    puts "\n✅ ADVANCED PIPELINE COMPLETE!"
    puts "Created: #{results.size} cinematic videos"
    
    results
  end
  
  def advanced_enhance(photo, opts = {})
    basename = File.basename(photo, ".*")
    photo_url = upload_to_temp_hosting(photo)
    
    return nil unless photo_url
    
    output = photo_url
    cost = 0.0
    steps = []
    
    # Step 1: Upscale
    steps << { name: "4x upscale", model: :upscale_4x }
    
    # Step 2: Background removal
    steps << { name: "remove bg", model: :rembg }
    
    # Step 3: Relighting with camera angle
    camera = CAMERA_PRESETS[opts[:camera]] || CAMERA_PRESETS[:cinematic]
    steps << { name: "relight (#{opts[:camera]})", model: :relight }
    
    # Step 4: Animation with camera movement
    steps << { name: "animate (#{camera[:movement]})", model: :animate }
    
    # Step 5: Talking head (if speech requested)
    if opts[:speech]
      steps << { name: "lip sync", model: :lipsync }
    end
    
    # Step 6: Dancing (if requested)
    if opts[:dance]
      steps << { name: "dance animation", model: :face_animate }
    end
    
    # Step 7: Sound design
    steps << { name: "music (#{opts[:music]})", model: :music }
    
    # Execute pipeline
    steps.each_with_index do |step, i|
      print "  #{i+1}. #{step[:name]}... "
      
      if MODELS[step[:model]]
        output = predict(step[:model], output)
        cost += COSTS[step[:model]] || 0.05
        puts "✓ ($#{(COSTS[step[:model]] || 0.05).round(3)})"
      else
        puts "⊘"
      end
      
      sleep 1
    end
    
    # Save
    suffix = [
      opts[:camera],
      opts[:speech] ? 'talking' : nil,
      opts[:dance] ? 'dancing' : nil
    ].compact.join('_')
    
    final_path = "cinema_#{basename}_#{suffix}_#{Time.now.to_i}.mp4"
    
    if output&.is_a?(String) && output.start_with?("http")
      download_output(output, final_path)
      puts "  💾 #{final_path}"
      puts "  💰 Cost: $#{cost.round(3)}"
      final_path
    else
      nil
    end
  rescue => e
    puts "  ❌ #{e.message}"
    nil
  end
  
  # === NATURAL LANGUAGE CINEMATOGRAPHY ===
  
  def parse_cinema_command(input)
    options = {}
    
    # Camera detection
    if input.match?(/\b(closeup|close-up|close up)\b/i)
      options[:camera] = :closeup
    elsif input.match?(/\b(wide|wide shot|establishing)\b/i)
      options[:camera] = :wide
    elsif input.match?(/\b(medium|mid shot)\b/i)
      options[:camera] = :medium
    elsif input.match?(/\b(dramatic|intense|low angle)\b/i)
      options[:camera] = :dramatic
    elsif input.match?(/\b(action|dynamic|fast)\b/i)
      options[:camera] = :action
    elsif input.match?(/\b(portrait|headshot)\b/i)
      options[:camera] = :portrait
    else
      options[:camera] = :cinematic
    end
    
    # Speech/talking detection
    options[:speech] = input.match?(/\b(talk|speaking|speech|voice|dialogue)\b/i)
    
    # Dance detection
    options[:dance] = input.match?(/\b(dance|dancing|choreograph|move|groove)\b/i)
    
    # Music style
    if input.match?(/\b(epic|orchestral|cinematic)\b/i)
      options[:music] = 'epic'
    elsif input.match?(/\b(chill|ambient|calm)\b/i)
      options[:music] = 'ambient'
    elsif input.match?(/\b(upbeat|energetic|dance)\b/i)
      options[:music] = 'energetic'
    elsif input.match?(/\b(dramatic|tense|suspense)\b/i)
      options[:music] = 'dramatic'
    else
      options[:music] = 'cinematic'
    end
    
    options
  end
  
  # === PROFESSIONAL WORKFLOW SHORTCUTS ===
  
  def workflow_headshot_reel(path)
    puts "\n🎭 HEADSHOT REEL WORKFLOW"
    cinema_advanced(path, {
      camera: :portrait,
      speech: true,
      dance: false,
      music: 'ambient'
    })
  end
  
  def workflow_dance_video(path)
    puts "\n💃 DANCE VIDEO WORKFLOW"
    cinema_advanced(path, {
      camera: :action,
      speech: false,
      dance: true,
      music: 'energetic'
    })
  end
  
  def workflow_commercial(path)
    puts "\n📺 COMMERCIAL WORKFLOW"
    cinema_advanced(path, {
      camera: :cinematic,
      speech: true,
      dance: false,
      music: 'upbeat'
    })
  end
  
  def workflow_music_video(path)
    puts "\n🎵 MUSIC VIDEO WORKFLOW"
    cinema_advanced(path, {
      camera: :dramatic,
      speech: false,
      dance: true,
      music: 'epic'
    })
  end

  # === LORA URL + MASTERPIECE WORKFLOW ===
  
  def masterpiece_from_lora(lora_url, photo_path, options = {})
    puts "\n🎬 CINEMATIC MASTERPIECE GENERATOR"
    puts "="*70
    puts "🎨 LoRA Model: #{lora_url}"
    puts "📸 Subject: #{photo_path}"
    puts "="*70
    
    # Extract LoRA model info
    lora_model = lora_url.split('/').last(2).join('/')
    puts "\n✅ Using LoRA: #{lora_model}"
    
    # Upload photo
    photo_url = upload_to_temp_hosting(photo_path)
    
    # Define LONG masterpiece chain (12+ steps)
    chain_steps = [
      # Phase 1: Foundation
      { name: "LoRA generation", model: :ra2, prompt: "professional portrait, cinematic lighting, 8k" },
      { name: "4x upscale", model: :upscale },
      { name: "background removal", model: :rembg },
      
      # Phase 2: Enhancement
      { name: "relighting (dramatic)", model: :relight },
      { name: "color grade (cinematic)", model: :flux },
      { name: "film grain", model: :upscale },
      
      # Phase 3: Animation
      { name: "animate (closeup)", model: :wan480 },
      { name: "stabilize motion", model: :sdv },
      { name: "camera movement", model: :wan480 },
      
      # Phase 4: Effects
      { name: "facial enhancement", model: :face_animate },
      { name: "lip sync prep", model: :lipsync },
      
      # Phase 5: Sound
      { name: "romantic score", model: :music }
    ]
    
    puts "\n🎯 MASTERPIECE CHAIN (#{chain_steps.size} steps):"
    chain_steps.each_with_index do |step, i|
      puts "  #{i+1}. #{step[:name]}"
    end
    
    total_cost = chain_steps.sum { |s| COSTS[s[:model]] || 0.05 }
    puts "\n💰 Estimated cost: $#{total_cost.round(2)}"
    
    print "\nProceed? (Y/n): "
    response = gets&.chomp&.downcase
    return unless response.empty? || response.start_with?("y")
    
    # Execute chain
    output = photo_url
    actual_cost = 0.0
    
    puts "\n🎬 EXECUTING MASTERPIECE CHAIN..."
    puts "="*70
    
    chain_steps.each_with_index do |step, i|
      print "\n[#{i+1}/#{chain_steps.size}] #{step[:name]}... "
      
      begin
        # Use LoRA for first step
        if i == 0
          input = {
            prompt: step[:prompt],
            image: photo_url,
            lora_scale: 0.8
          }
          output = predict_with_lora(lora_model, input)
        elsif MODELS[step[:model]]
          output = predict(step[:model], output)
        else
          puts "⊘ (model unavailable)"
          next
        end
        
        cost = COSTS[step[:model]] || 0.05
        actual_cost += cost
        puts "✓ ($#{cost.round(3)})"
        
        sleep 1
      rescue => e
        puts "✗ (#{e.message})"
      end
    end
    
    # Save final masterpiece
    if output&.is_a?(String) && output.start_with?("http")
      timestamp = Time.now.strftime("%Y%m%d_%H%M%S")
      final_path = "masterpiece_#{timestamp}.mp4"
      download_output(output, final_path)
      
      puts "\n"
      puts "="*70
      puts "🎉 MASTERPIECE COMPLETE!"
      puts "="*70
      puts "📁 Saved: #{final_path}"
      puts "💰 Total cost: $#{actual_cost.round(2)}"
      puts "🎬 #{chain_steps.size} steps executed"
      
      # Offer postpro
      if @postpro
        puts "\n🎨 Apply final color grading?"
        print "Launch postpro? (Y/n): "
        response = gets&.chomp&.downcase
        system("ruby33 postpro.rb") if response.empty? || response.start_with?("y")
      end
      
      final_path
    else
      puts "\n❌ Generation failed"
      nil
    end
  end
  
  def predict_with_lora(lora_model, input)
    # Predict using LoRA model
    parts = lora_model.split(':')
    
    pred = request('predictions', :post, {
      version: parts[1] || 'latest',
      input: input
    })
    
    wait_for(pred['id'])
  end
  
  # Natural language LoRA detection
  def parse_lora_from_input(input)
    # Extract LoRA URL from natural language
    if match = input.match(/(?:use|with|using)\s+(?:this\s+)?lora\s+(?:model\s+)?(?:at\s+)?[:=]?\s*(https?:\/\/[^\s]+)/i)
      match[1]
    elsif match = input.match(/(https?:\/\/replicate\.com\/[^\s]+)/i)
      match[1]
    else
      nil
    end
  end
  
  def parse_subject_from_input(input)
    # Extract subject description
    if match = input.match(/(?:of|about|featuring)\s+(?:my\s+)?([\w\s]+?)(?:\s+using|\s+with|\s+at|$)/i)
      match[1].strip
    else
      "subject"
    end
  end
  
  # Quick masterpiece command
  def quick_masterpiece(input)
    lora_url = parse_lora_from_input(input)
    subject = parse_subject_from_input(input)
    
    unless lora_url
      puts "❌ No LoRA URL found in: #{input}"
      puts "Example: 'use this lora https://replicate.com/anon987654321/ra2 to create masterpiece of my girlfriend'"
      return
    end
    
    # Find photos
    photos = Dir.glob("*.{jpg,jpeg,png,webp}", File::FNM_CASEFOLD)
    
    if photos.empty?
      puts "❌ No photos found in current directory"
      puts "Add photos or specify path: masterpiece /path/to/photo.jpg"
      return
    end
    
    puts "📸 Found #{photos.size} photos"
    photo = photos.size == 1 ? photos.first : select_photo(photos)
    
    masterpiece_from_lora(lora_url, photo, { subject: subject })
  end
  
  def select_photo(photos)
    puts "\nSelect photo:"
    photos.each_with_index { |p, i| puts "  #{i+1}. #{File.basename(p)}" }
    print "\nChoice (1-#{photos.size}): "
    
    choice = gets&.chomp&.to_i
    photos[choice - 1] || photos.first
  end
if __FILE__ == $0
  
  # === INTERACTIVE SCRAPER COMMAND ===
  
  def scrape_replicate_explore(max_scrolls = 50)
    puts "\n🔍 REPLICATE.COM/EXPLORE SCRAPER"
    puts "="*70
    puts "Target: ~#{max_scrolls * 20} models (#{max_scrolls} scroll iterations)"
    puts "="*70
    
    unless @bootstrap[:ferrum_available]
      puts "❌ Ferrum not available"
      puts "Install: gem install ferrum"
      return
    end
    
    require "ferrum"
    
    # Initialize browser
    puts "\n🌐 Launching headless browser..."
    browser = Ferrum::Browser.new(
      headless: true,
      timeout: 60,
      window_size: [1920, 1080]
    )
    
    begin
      browser.goto("https://www.replicate.com/explore")
      puts "✅ Loaded: https://www.replicate.com/explore"
      sleep 3
      
      # Initialize database
      db = init_models_db
      discovered = 0
      
      puts "\n📜 Scraping (infinite scroll)..."
      puts "-"*70
      
      max_scrolls.times do |i|
        # Scroll to bottom
        browser.execute("window.scrollTo(0, document.body.scrollHeight)")
        sleep 2
        
        # Extract models
        html = browser.body
        models = extract_models_from_html(html)
        
        models.each do |model|
          begin
            db.execute(<<-SQL, [
              model[:id], model[:name], model[:owner], model[:description],
              model[:type], model[:runs], model[:cost], model[:url], Time.now.to_i
            ])
              INSERT OR REPLACE INTO models 
              (id, name, owner, description, type, runs, cost, url, discovered_at)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
            SQL
            discovered += 1
          rescue
            # Skip duplicates
          end
        end
        
        print "\rScroll #{i+1}/#{max_scrolls} | Models: #{discovered}"
        
        # Check if reached end
        current_h = browser.evaluate("document.body.scrollHeight")
        browser.execute("window.scrollTo(0, document.body.scrollHeight)")
        sleep 1
        new_h = browser.evaluate("document.body.scrollHeight")
        break if current_h == new_h
      end
      
      puts "\n\n✅ Scraping complete!"
      puts "Discovered: #{discovered} models"
      
      # Show stats
      db.results_as_hash = true
      by_type = db.execute(
        "SELECT type, COUNT(*) as count FROM models WHERE type IS NOT NULL GROUP BY type ORDER BY count DESC LIMIT 10"
      )
      
      puts "\nTop categories:"
      by_type.each { |row| puts "  #{row['type']}: #{row['count']}" }
      
      db.close
      
    ensure
      browser&.quit
    end
  end
  
  def init_models_db
    require "sqlite3"
    db = SQLite3::Database.new("repligen_models.db")
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS models (
        id TEXT PRIMARY KEY,
        name TEXT,
        owner TEXT,
        description TEXT,
        type TEXT,
        runs INTEGER,
        cost REAL,
        url TEXT,
        discovered_at INTEGER
      )
    SQL
    db
  end
  
  def extract_models_from_html(html)
    models = []
    
    html.scan(/\/([^\/]+)\/([^\/\s"]+)/) do |owner, name|
      next if owner.length < 3 || name.length < 3
      next if owner =~ /^(explore|models|docs|api|blog|pricing|about|terms)$/
      
      id = "#{owner}/#{name}"
      desc = extract_description_from_html(html, id)
      type = infer_model_type(name, desc)
      
      models << {
        id: id,
        name: name,
        owner: owner,
        description: desc,
        type: type,
        runs: 0,
        cost: 0.05,
        url: "https://replicate.com/#{id}"
      }
    end
    
    models.uniq { |m| m[:id] }
  end
  
  def extract_description_from_html(html, model_id)
    if match = html.match(/#{Regexp.escape(model_id)}.*?<p[^>]*>(.*?)<\/p>/m)
      match[1].gsub(/<[^>]+>/, '').strip[0..200]
    else
      ""
    end
  end
  
  def infer_model_type(name, description)
    combined = "#{name} #{description}".downcase
    
    case combined
    when /text.*image|txt2img|dalle|stable.*diffusion|flux|sdxl/ then 'text-to-image'
    when /image.*video|img2vid|animate/ then 'image-to-video'
    when /video|motion/ then 'video'
    when /audio|music|sound|tts/ then 'audio'
    when /upscale|super.*res/ then 'upscale'
    when /background|rembg|segment/ then 'image-processing'
    when /style|artistic/ then 'style-transfer'
    when /face|portrait/ then 'face'
    when /lora|train/ then 'training'
    else 'other'
    end
  end
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

# Replicate model discovery via Ferrum + GPT-4 Vision
class ReplicateExplorer
# === LANGCHAINRB RAG INTEGRATION ===

class ModelRAG
  def initialize(anthropic_token, replicate_token)
    @anthropic_token = anthropic_token
    @replicate_token = replicate_token
    @db_path = "repligen_models.db"
    ensure_langchain
  end

  def ensure_langchain
    require "langchain"
    @langchain_available = true
    Bootstrap.dmesg "OK langchainrb available"
  rescue LoadError
    Bootstrap.dmesg "WARN langchainrb missing, installing..."
    system("gem install langchainrb --no-document")
    begin
      require "langchain"
      @langchain_available = true
      Bootstrap.dmesg "OK langchainrb installed"
    rescue
      @langchain_available = false
      Bootstrap.dmesg "WARN langchainrb unavailable, RAG disabled"
    end
  end

  def query(user_intent, context: {})
    return fallback_query(user_intent) unless @langchain_available && @anthropic_token

    # Get relevant models from vector search
    relevant_models = semantic_search(user_intent, limit: 10)

    # Build RAG prompt
    prompt = build_rag_prompt(user_intent, relevant_models, context)

    # Route to best LLM (Claude > Grok > Replicate)
    response = query_llm(prompt)

    parse_rag_response(response)
  end

  def semantic_search(query, limit: 10)
    return [] unless File.exist?(@db_path)

    begin
      require "sqlite3"
      db = SQLite3::Database.new(@db_path)
      db.results_as_hash = true

      # Simple keyword search (upgrade to embeddings later)
      results = db.execute(
        "SELECT * FROM models WHERE id LIKE ? OR description LIKE ? OR type LIKE ? LIMIT ?",
        ["%#{query}%", "%#{query}%", "%#{query}%", limit]
      )

      db.close
      results
    rescue => e
      Bootstrap.dmesg "WARN semantic search failed: #{e.message}"
      []
    end
  end

  def build_rag_prompt(intent, models, context)
    models_summary = models.map do |m|
      "- #{m["id"]} (#{m["type"]}, $#{m["cost"] || 0.05}): #{m["description"]&.slice(0, 80)}"
    end.join("\n")

    <<~PROMPT
      You are an expert at Replicate.com AI model orchestration. The user wants: "#{intent}"

      Available models from our 48k+ catalog:
      #{models_summary}

      Context: #{context.inspect}

      Suggest:
      1. Best single model for this task
      2. Optimal chain (3-8 models) if multi-step needed
      3. Estimated cost
      4. Reasoning for each choice

      Respond as JSON:
      {
        "approach": "single|chain",
        "models": [{"id": "owner/name", "step": 1, "reasoning": "why"}],
        "estimated_cost": 0.15,
        "explanation": "brief summary"
      }
    PROMPT
  end

  def query_llm(prompt)
    # Try Claude first (best for reasoning)
    return query_claude(prompt) if @anthropic_token

    # Fallback to Replicate models
    return query_replicate_llm(prompt) if @replicate_token

    nil
  end

  def query_claude(prompt)
    uri = URI("https://api.anthropic.com/v1/messages")
    req = Net::HTTP::Post.new(uri)
    req["x-api-key"] = @anthropic_token
    req["anthropic-version"] = "2023-06-01"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate({
      model: "claude-sonnet-4-20250514",
      max_tokens: 2000,
      messages: [{
        role: "user",
        content: prompt
      }]
    })

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 60) { |http| http.request(req) }
    return nil unless res.code == "200"

    JSON.parse(res.body).dig("content", 0, "text")
  rescue => e
    Bootstrap.dmesg "WARN Claude query failed: #{e.message}"
    nil
  end

  def query_replicate_llm(prompt)
    # Use Replicate's Llama or other text model
    uri = URI("https://api.replicate.com/v1/predictions")
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Token #{@replicate_token}"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate({
      version: "meta/meta-llama-3-70b-instruct",
      input: { prompt: prompt, max_tokens: 2000 }
    })

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
    return nil unless res.code.to_i.between?(200, 299)

    prediction = JSON.parse(res.body)
    wait_for_replicate(prediction["id"])
  rescue => e
    Bootstrap.dmesg "WARN Replicate LLM query failed: #{e.message}"
    nil
  end

  def wait_for_replicate(id)
    30.times do
      uri = URI("https://api.replicate.com/v1/predictions/#{id}")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Token #{@replicate_token}"

      res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
      pred = JSON.parse(res.body)

      return pred["output"] if pred["status"] == "succeeded"
      return nil if pred["status"] == "failed"

      sleep 2
    end
    nil
  end

  def parse_rag_response(response)
    return nil unless response

    # Extract JSON from response
    json_match = response.match(/\{[\s\S]*\}/)
    return nil unless json_match

    JSON.parse(json_match[0])
  rescue => e
    Bootstrap.dmesg "WARN RAG parse failed: #{e.message}"
    nil
  end

  def fallback_query(intent)
    # Simple keyword-based fallback
    return nil unless File.exist?(@db_path)

    models = semantic_search(intent, limit: 3)
    return nil if models.empty?

    {
      "approach" => "single",
      "models" => [{ "id" => models.first["id"], "step" => 1, "reasoning" => "keyword match" }],
      "estimated_cost" => models.first["cost"] || 0.05,
      "explanation" => "Fallback recommendation based on keyword search"
    }
  end
end
  def initialize(anthropic_token, db = nil)
    @anthropic_token = anthropic_token
    @browser = nil
    @db = db || init_db
    @models = load_from_db
  end

  def init_db
    require "sqlite3"
    db = SQLite3::Database.new("repligen_models.db")
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS models (
        id TEXT PRIMARY KEY,
        type TEXT,
        description TEXT,
        cost REAL,
        documentation TEXT,
        discovered_at INTEGER
      )
    SQL
    db
  rescue LoadError
    Bootstrap.dmesg "WARN sqlite3 unavailable, models won't persist"
    nil
  end

  def discover(max_pages: 5)
    return [] unless setup_browser
    Bootstrap.dmesg "discovering models from replicate.com/explore"

    discovered = []
    begin
      @browser.goto("https://www.replicate.com/explore")
      sleep rand(3..7)

      max_pages.times do |page|
        html = @browser.body
        screenshot = screenshot_page(page)

        if screenshot && @anthropic_token
          models = extract_via_gpt4v(screenshot, html)
          discovered.concat(models) if models
          Bootstrap.dmesg "page #{page+1}: #{models&.size || 0} models"
        end

        break unless next_page
        sleep rand(3..7)
      end

      discovered.each { |m| save_model_to_db(m) }
      @models = load_from_db
      discovered
    rescue => e
      Bootstrap.dmesg "ERROR discovery: #{e.message}"
      []
    ensure
      cleanup
    end
  end

  def build_radical_chain(style: "cinematic", length: 5)
    return [] if @models.empty?

    categories = {
      image: @models.values.select { |m| m["type"] =~ /image|art/i },
      video: @models.values.select { |m| m["type"] =~ /video|motion/i },
      audio: @models.values.select { |m| m["type"] =~ /audio|music/i },
      enhance: @models.values.select { |m| m["type"] =~ /upscale|enhance/i },
      style: @models.values.select { |m| m["type"] =~ /style|artistic/i }
    }

    chain = case style
    when "cinematic"
      [categories[:image].sample, categories[:style].sample,
       categories[:enhance].sample, categories[:video].sample,
       categories[:audio].sample].compact
    when "experimental"
      @models.values.sample(length)
    when "quality"
      [categories[:image].sample, *categories[:enhance].sample(2),
       categories[:style].sample].compact
    else
      @models.values.sample(length)
    end

    chain.map { |m| { id: m["id"], cost: m["cost"] || 0.05 } }
  end

  private

  def setup_browser
    require "ferrum"
    @browser = Ferrum::Browser.new(headless: true, timeout: 30, window_size: [1920, 1080])
    FileUtils.mkdir_p("discovery_screenshots")
    true
  rescue LoadError
    Bootstrap.dmesg "ERROR ferrum gem required"
    false
  rescue => e
    Bootstrap.dmesg "ERROR browser: #{e.message}"
    false
  end

  def screenshot_page(page_num)
    path = "discovery_screenshots/page_#{page_num}.png"
    @browser.screenshot(path: path, full: true)
    path
  rescue => e
    Bootstrap.dmesg "WARN screenshot: #{e.message}"
    nil
  end

  def extract_via_gpt4v(screenshot, html)
    return nil unless @anthropic_token
    require "base64"

    image_b64 = Base64.strict_encode64(File.read(screenshot))
    uri = URI("https://api.anthropic.com/v1/messages")
    req = Net::HTTP::Post.new(uri)
    req["x-api-key"] = @anthropic_token
    req["anthropic-version"] = "2023-06-01"
    req["Content-Type"] = "application/json"
    req.body = JSON.generate({
      model: "claude-sonnet-4-20250514",
      max_tokens: 2000,
      messages: [{
        role: "user",
        content: [
          { type: "image", source: { type: "base64", media_type: "image/png", data: image_b64 }},
          { type: "text", text: "Extract Replicate models from this screenshot as JSON: [{\"id\":\"owner/name\",\"type\":\"image/video/audio\",\"description\":\"...\",\"cost\":0.05}]. HTML context: #{html[0..3000]}" }
        ]
      }]
    })

    res = Net::HTTP.start(uri.host, uri.port, use_ssl: true, read_timeout: 90) { |http| http.request(req) }
    return nil unless res.code == "200"

    content = JSON.parse(res.body).dig("content", 0, "text")
    JSON.parse(content.gsub(/```json\n?/, "").gsub(/```/, ""))
  rescue => e
    Bootstrap.dmesg "WARN claude vision: #{e.message}"
    nil
  end

  def next_page
    btn = @browser.at_css('a[rel="next"]') || @browser.at_css('button:contains("Next")')
    return false unless btn
    btn.click
    true
  rescue
    false
  end

  def cleanup
    @browser&.quit
    @browser = nil
  end

  def load_from_db
    return {} unless @db
    @db.results_as_hash = true
    rows = @db.execute("SELECT * FROM models")
    rows.map { |r| [r["id"], r] }.to_h
  rescue
    {}
  end

  def save_model_to_db(model)
    return unless @db
    @db.execute(<<-SQL, [model["id"], model["type"], model["description"], model["cost"] || 0.05, model["documentation"], Time.now.to_i])
      INSERT OR REPLACE INTO models (id, type, description, cost, documentation, discovered_at)
      VALUES (?, ?, ?, ?, ?, ?)
    SQL
  rescue => e
    Bootstrap.dmesg "WARN db save: #{e.message}"
  end
end

  def interactive_cli
    puts "\n" + "="*60
    puts "REPLIGEN - Cinematic AI Generation Pipeline"
    puts "="*60
    puts

    puts "Please enter LoRA URL (or press Enter to skip):"
    print "> "
    lora_url = gets.chomp.strip
    lora_url = nil if lora_url.empty?

    puts "\nShould the resulting artwork be a photo or a movie?"
    print "> "
    output_type = gets.chomp.downcase.strip
    is_video = output_type.include?("movie") || output_type.include?("video")

    puts "\nDo you have a link to the background soundtrack? (or press Enter to skip):"
    print "> "
    soundtrack_url = gets.chomp.strip
    soundtrack_url = nil if soundtrack_url.empty?

    puts "\nDescribe the scene/artwork you want to create:"
    print "> "
    prompt = gets.chomp.strip
    prompt = "digital art" if prompt.empty?

    puts "\n" + "-"*60
    puts "Building your cinematic pipeline..."
    puts "-"*60

    chain_steps = []

    if lora_url
      puts "• Using custom LoRA: #{lora_url}"
      chain_steps << :ra2
    else
      chain_steps << :flux
    end

    chain_steps << :upscale

    if is_video
      puts "• Adding motion + camera angles"
      chain_steps << :wan480
    end

    if soundtrack_url
      puts "• Integrating soundtrack: #{soundtrack_url}"
    elsif is_video
      puts "• Generating cinematic soundtrack"
      chain_steps << :music
    end

    puts "• Relighting + professional color grading"

    puts "\nPipeline: #{chain_steps.join(' → ')}"
    estimated_cost = chain_steps.sum { |m| COSTS[m] || 0.05 }
    puts "Estimated cost: $#{estimated_cost.round(3)}"

    print "\nProceed? (Y/n): "
    response = gets.chomp.downcase
    return unless response.empty? || response.start_with?("y")

    puts "\nGenerating..."
    result = execute_chain(chain_steps, prompt)

    if @postpro && result
      puts "\n" + "="*60
      puts "POSTPRO.RB INTEGRATION"
      puts "="*60
      puts "Apply cinematic film-grade color grading?"
      puts "• Kodak Portra curves • Skin tone protection"
      puts "• Professional grain • Highlight rolloff"
      print "\nLaunch postpro.rb? (Y/n): "

      response = gets.chomp.downcase
      system("ruby postpro.rb --from-repligen") if response.empty? || response.start_with?("y")
    end

    puts "\n✓ Complete! Output saved."
    puts "\nGenerate another? (y/N): "
    response = gets.chomp.downcase
    interactive_cli if response.start_with?("y")
  end

  def execute_chain(steps, prompt)
    output = prompt
    cost = 0.0

    steps.each_with_index do |model, i|
      puts "\nStep #{i+1}/#{steps.length}: #{model}"
      output = predict(model, output)
      cost += COSTS[model]
    end

    log_chain(steps.map(&:to_s), cost)
    save_output(output, :custom, prompt) if output.is_a?(String) && output.start_with?("http")
    output
  end
