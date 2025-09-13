#!/usr/bin/env ruby

# PounceKeys - Keystroke Analysis Tool
# Analyzes typing patterns and timing for ergonomic insights

require 'json'
require 'time'

module PounceKeys
  class Monitor
    attr_reader :data

    def initialize
      @data = []
      @running = false
    end

    def start
      @running = true
      puts "Starting keystroke monitoring..."
      puts "Press Ctrl+C to stop"
      
      begin
        monitor_keystrokes
      rescue Interrupt
        stop
      end
    end

    def stop
      @running = false
      puts "\nMonitoring stopped. Captured #{@data.length} keystrokes."
    end

    private

    def monitor_keystrokes
      # Simulated keystroke monitoring
      # In a real implementation, this would use platform-specific APIs
      while @running
        sleep(0.1)
        # Simulate random keystroke data for demonstration
        if rand < 0.3
          record_keystroke(generate_sample_keystroke)
        end
      end
    end

    def record_keystroke(keystroke)
      @data << keystroke
    end

    def generate_sample_keystroke
      {
        key: ('a'..'z').to_a.sample,
        timestamp: Time.now.to_f,
        duration: rand(0.05..0.3),
        pressure: rand(0.1..1.0)
      }
    end
  end

  class Analyzer
    def initialize(keystroke_data)
      @data = keystroke_data
    end

    def generate_stats
      Stats.new(@data)
    end
  end

  class Stats
    def initialize(data)
      @data = data
    end

    def summary
      return "No data available" if @data.empty?

      total_keys = @data.length
      duration = @data.last[:timestamp] - @data.first[:timestamp]
      wpm = (total_keys / 5.0) / (duration / 60.0)

      <<~SUMMARY
        Keystroke Analysis Summary
        ==========================
        Total keystrokes: #{total_keys}
        Duration: #{duration.round(2)} seconds
        Words per minute: #{wpm.round(2)}
        Average key duration: #{average_duration.round(3)} seconds
        Most common key: #{most_common_key}
        
        Typing rhythm: #{rhythm_analysis}
      SUMMARY
    end

    def export_json
      {
        total_keystrokes: @data.length,
        duration: @data.last[:timestamp] - @data.first[:timestamp],
        average_duration: average_duration,
        most_common_key: most_common_key,
        keystrokes: @data
      }.to_json
    end

    private

    def average_duration
      return 0 if @data.empty?
      @data.sum { |k| k[:duration] } / @data.length.to_f
    end

    def most_common_key
      return 'none' if @data.empty?
      @data.map { |k| k[:key] }.tally.max_by { |_, count| count }&.first || 'none'
    end

    def rhythm_analysis
      return 'insufficient data' if @data.length < 10
      
      intervals = []
      @data.each_cons(2) do |a, b|
        intervals << b[:timestamp] - a[:timestamp]
      end

      avg_interval = intervals.sum / intervals.length.to_f
      variance = intervals.sum { |i| (i - avg_interval) ** 2 } / intervals.length.to_f

      if variance < 0.01
        'very consistent'
      elsif variance < 0.05
        'consistent'
      elsif variance < 0.1
        'variable'
      else
        'irregular'
      end
    end
  end
end

# Command line interface
if __FILE__ == $0
  if ARGV.include?('--help') || ARGV.include?('-h')
    puts <<~HELP
      PounceKeys - Keystroke Analysis Tool
      
      Usage: #{$0} [options]
      
      Options:
        --monitor    Start keystroke monitoring
        --analyze    Analyze existing data
        --help       Show this help
        
      Examples:
        ruby pouncekeys.rb --monitor
        ruby pouncekeys.rb --analyze
    HELP
    exit 0
  end

  if ARGV.include?('--monitor')
    monitor = PounceKeys::Monitor.new
    monitor.start
    
    if monitor.data.any?
      analyzer = PounceKeys::Analyzer.new(monitor.data)
      stats = analyzer.generate_stats
      puts "\n" + stats.summary
      
      # Save data
      File.write('keystroke_data.json', stats.export_json)
      puts "\nData saved to keystroke_data.json"
    end
  elsif ARGV.include?('--analyze')
    if File.exist?('keystroke_data.json')
      data = JSON.parse(File.read('keystroke_data.json'), symbolize_names: true)
      analyzer = PounceKeys::Analyzer.new(data[:keystrokes] || [])
      stats = analyzer.generate_stats
      puts stats.summary
    else
      puts "No data file found. Run with --monitor first."
    end
  else
    puts "Use --help for usage information"
  end
end