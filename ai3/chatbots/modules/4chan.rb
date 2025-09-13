#!/usr/bin/env ruby

# 4chan Integration Module  
# Handles 4chan posting and monitoring

module AI3
  module Chatbots
    class FourChan
      def initialize
        @connected = false
        @monitored_boards = []
        @monitoring = false
      end

      def connect(config)
        @boards = config[:boards] || ['g', 'pol', 'b']
        @post_delay = config[:post_delay] || 30  # Rate limiting
        @user_agent = config[:user_agent] || 'AI3Bot/1.0'
        
        @connected = true
        puts "Connected to 4chan API"
      rescue => e
        puts "4chan connection failed: #{e.message}"
      end

      def on_message(&block)
        @message_handler = block
        start_monitoring if @connected
      end

      def send_message(options = {})
        return unless @connected
        
        board = options[:board]
        thread_id = options[:thread_id]
        content = options[:content]
        
        # 4chan posting requires careful rate limiting and captcha handling
        post_to_thread(board, thread_id, content)
      end

      def reply(original_message, content)
        board = original_message.platform_data[:board]
        thread_id = original_message.platform_data[:thread_id]
        post_id = original_message.platform_data[:post_id]
        
        # Format as reply with >>post_id
        reply_content = ">>#{post_id}\n#{content}"
        
        send_message(
          board: board,
          thread_id: thread_id,
          content: reply_content
        )
      end

      def format_response(response)
        # 4chan specific formatting
        # - Greentext support
        # - Link formatting
        # - Character limits
        
        # Convert bullet points to greentext
        response = response.gsub(/^- (.+)/, '> \1')
        response = response.gsub(/^\* (.+)/, '> \1')
        
        # Limit response length
        if response.length > 1000
          response = response[0..996] + "..."
        end
        
        # Remove markdown formatting that 4chan doesn't support
        response = response.gsub(/\*\*(.*?)\*\*/, '\1')  # Remove bold
        response = response.gsub(/\*(.*?)\*/, '\1')      # Remove italic
        
        response
      end

      def should_respond?(message)
        content = message.content.downcase
        
        # Respond to direct mentions/replies or specific keywords
        return true if content.include?('ai3') || content.include?('bot')
        return true if message.platform_data[:mentions_bot]
        
        # Respond to technology discussions on /g/
        if message.platform_data[:board] == 'g'
          return true if content.match?(/\b(programming|linux|ai|code)\b/)
        end
        
        false
      end

      def disconnect
        @monitoring = false
        @connected = false
        puts "Disconnected from 4chan"
      end

      private

      def start_monitoring
        @monitoring = true
        
        Thread.new do
          while @monitoring
            @boards.each do |board|
              monitor_board(board)
            end
            sleep(10)  # Rate limiting
          end
        end
      end

      def monitor_board(board)
        return unless @monitoring
        
        begin
          # Fetch recent threads/posts from board
          # This would use 4chan's JSON API
          
          threads = fetch_board_threads(board)
          threads.each do |thread|
            process_thread_posts(board, thread)
          end
          
        rescue => e
          puts "Error monitoring board #{board}: #{e.message}"
        end
      end

      def fetch_board_threads(board)
        # Placeholder for 4chan API call
        # Would fetch from: https://a.4cdn.org/#{board}/threads.json
        []
      end

      def process_thread_posts(board, thread)
        # Process new posts in thread
        thread['posts']&.each do |post|
          next unless should_process_post?(post)
          
          message = create_message_from_post(board, thread, post)
          @message_handler&.call(message)
        end
      end

      def should_process_post?(post)
        # Filter posts to process
        return false if post['name']&.include?('AI3Bot')  # Don't respond to self
        return false if post['time'] < (Time.now - 300).to_i  # Only recent posts
        
        true
      end

      def create_message_from_post(board, thread, post)
        AI3::Message.new(
          content: post['com'] || '',  # Post content
          user_id: post['id'].to_s,
          channel: "/#{board}/",
          timestamp: Time.at(post['time']),
          platform_data: {
            from_bot: false,
            mentions_bot: (post['com'] || '').include?('AI3'),
            direct_message: false,
            board: board,
            thread_id: thread['no'],
            post_id: post['no'],
            is_op: post['resto'] == 0
          }
        )
      end

      def post_to_thread(board, thread_id, content)
        # Placeholder for 4chan posting
        # Real implementation would need:
        # - Captcha solving
        # - Proper rate limiting  
        # - Error handling for bans/blocks
        
        puts "Posting to /#{board}/#{thread_id}: #{content[0..50]}..."
        
        # Add artificial delay for rate limiting
        sleep(@post_delay)
      end
    end
  end
end