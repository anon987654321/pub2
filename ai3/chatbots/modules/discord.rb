#!/usr/bin/env ruby

# Discord Integration Module
# Handles Discord bot functionality

module AI3
  module Chatbots
    class Discord
      def initialize
        @client = nil
        @connected = false
      end

      def connect(config)
        require 'discordrb'
        
        @client = Discordrb::Bot.new(
          token: config[:token],
          intents: [:server_messages, :direct_messages]
        )
        
        @connected = true
        puts "Connected to Discord"
      rescue LoadError
        puts "discordrb gem not available - Discord integration disabled"
      rescue => e
        puts "Discord connection failed: #{e.message}"
      end

      def on_message(&block)
        return unless @client && @connected
        
        @client.message do |event|
          message = AI3::Message.new(
            content: event.content,
            user_id: event.user.id.to_s,
            channel: event.channel.name,
            timestamp: event.timestamp,
            platform_data: {
              from_bot: event.user.bot_account?,
              mentions_bot: event.content.include?(@client.profile.mention),
              direct_message: event.channel.private?,
              user_roles: event.user.roles.map(&:name),
              discord_event: event
            }
          )
          
          block.call(message)
        end
        
        @client.run
      end

      def send_message(options = {})
        return unless @client && @connected
        
        channel = find_channel(options[:channel])
        return unless channel
        
        channel.send_message(options[:content])
      end

      def reply(original_message, content)
        return unless @client && @connected
        
        discord_event = original_message.platform_data[:discord_event]
        return unless discord_event
        
        discord_event.respond(content)
      end

      def format_response(response)
        # Discord supports markdown formatting
        response = response.gsub(/\*\*(.*?)\*\*/, '**\1**')  # Bold
        response = response.gsub(/\*(.*?)\*/, '*\1*')        # Italic
        response = response.gsub(/`(.*?)`/, '`\1`')          # Code
        
        # Limit message length (Discord limit is 2000 characters)
        if response.length > 1900
          response = response[0..1896] + "..."
        end
        
        response
      end

      def should_respond?(message)
        # Respond to mentions and DMs by default
        message.mentions_bot? || message.is_direct_message?
      end

      def disconnect
        @client&.stop
        @connected = false
        puts "Disconnected from Discord"
      end

      private

      def find_channel(channel_name)
        return nil unless @client
        
        # Handle channel ID or name
        if channel_name.is_a?(Integer) || channel_name.match?(/^\d+$/)
          @client.channel(channel_name.to_i)
        else
          @client.servers.values.flat_map(&:channels).find do |channel|
            channel.name == channel_name.to_s.gsub(/^#/, '')
          end
        end
      end
    end
  end
end