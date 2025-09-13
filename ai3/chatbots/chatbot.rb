#!/usr/bin/env ruby

# AI3 Chatbot Orchestrator
# Main chatbot class for managing multi-platform integrations

require_relative '../lib/assistant_orchestrator'
require_relative 'modules/discord'
require_relative 'modules/snapchat'
require_relative 'modules/4chan'
require_relative 'modules/onlyfans'
require_relative 'modules/reddit'

module AI3
  class Chatbot
    attr_reader :platform, :config, :assistant

    def initialize(platform:, config:)
      @platform = platform
      @config = config
      @assistant = AssistantOrchestrator.new
      @module = load_platform_module
      @running = false
    end

    def start
      puts "Starting #{@platform} chatbot..."
      @running = true
      @module.connect(@config)
      
      @module.on_message do |message|
        handle_message(message)
      end
      
      puts "#{@platform} chatbot is now running"
    end

    def stop
      @running = false
      @module.disconnect if @module.respond_to?(:disconnect)
      puts "#{@platform} chatbot stopped"
    end

    def send_message(options = {})
      return unless @running
      @module.send_message(options)
    end

    def reply(original_message, content)
      return unless @running
      @module.reply(original_message, content)
    end

    private

    def load_platform_module
      case @platform.to_sym
      when :discord
        Chatbots::Discord.new
      when :snapchat
        Chatbots::Snapchat.new
      when :'4chan'
        Chatbots::FourChan.new
      when :onlyfans
        Chatbots::OnlyFans.new
      when :reddit
        Chatbots::Reddit.new
      else
        raise "Unsupported platform: #{@platform}"
      end
    end

    def handle_message(message)
      return if message.from_bot?
      return unless should_respond?(message)

      begin
        # Process message with appropriate assistant
        assistant_type = determine_assistant_type(message)
        response = @assistant.process(
          input: message.content,
          assistant: assistant_type,
          context: build_context(message)
        )

        # Apply platform-specific formatting
        formatted_response = @module.format_response(response)
        
        # Send response
        reply(message, formatted_response)
        
      rescue => e
        puts "Error handling message: #{e.message}"
        reply(message, "Sorry, I encountered an error processing your message.")
      end
    end

    def should_respond?(message)
      # Check if bot should respond to this message
      return true if message.mentions_bot?
      return true if message.is_direct_message?
      return true if message.content.match?(/\b(help|ai3|assistant)\b/i)
      
      # Platform-specific logic
      @module.should_respond?(message)
    end

    def determine_assistant_type(message)
      # Analyze message content to determine best assistant
      content = message.content.downcase
      
      return :healthcare if content.match?(/\b(health|medical|doctor|medicine)\b/)
      return :lawyer if content.match?(/\b(legal|law|contract|attorney)\b/)
      return :trader if content.match?(/\b(stock|crypto|trading|investment)\b/)
      return :hacker if content.match?(/\b(security|hack|vulnerability|pentest)\b/)
      return :sys_admin if content.match?(/\b(server|linux|admin|system)\b/)
      return :web_developer if content.match?(/\b(web|html|css|javascript|react)\b/)
      return :seo if content.match?(/\b(seo|search|ranking|optimization)\b/)
      
      # Default to general assistant
      :base
    end

    def build_context(message)
      {
        platform: @platform,
        user_id: message.user_id,
        channel: message.channel,
        timestamp: message.timestamp,
        is_public: !message.is_direct_message?,
        user_roles: message.user_roles || []
      }
    end
  end

  # Message abstraction for cross-platform compatibility
  class Message
    attr_reader :content, :user_id, :channel, :timestamp, :platform_data

    def initialize(content:, user_id:, channel:, timestamp:, platform_data: {})
      @content = content
      @user_id = user_id
      @channel = channel
      @timestamp = timestamp
      @platform_data = platform_data
    end

    def from_bot?
      @platform_data[:from_bot] || false
    end

    def mentions_bot?
      @platform_data[:mentions_bot] || false
    end

    def is_direct_message?
      @platform_data[:direct_message] || false
    end

    def user_roles
      @platform_data[:user_roles] || []
    end
  end
end