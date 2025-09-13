#!/usr/bin/env ruby

# Reddit Integration Module
# Handles Reddit bot functionality

module AI3
  module Chatbots
    class Reddit
      def initialize
        @connected = false
        @praw_client = nil
        @monitored_subreddits = []
      end

      def connect(config)
        @client_id = config[:client_id]
        @client_secret = config[:client_secret]
        @user_agent = config[:user_agent] || 'AI3Bot/1.0'
        @username = config[:username]
        @password = config[:password]
        @subreddits = config[:subreddits] || ['AskReddit', 'programming', 'technology']
        
        # Initialize Reddit API client (PRAW equivalent in Ruby)
        setup_reddit_client
        @connected = true
        puts "Connected to Reddit API"
      rescue => e
        puts "Reddit connection failed: #{e.message}"
      end

      def on_message(&block)
        @message_handler = block
        start_monitoring if @connected
      end

      def send_message(options = {})
        return unless @connected
        
        if options[:type] == 'comment'
          post_comment(options[:submission_id], options[:content])
        elsif options[:type] == 'reply'
          reply_to_comment(options[:comment_id], options[:content])
        elsif options[:type] == 'pm'
          send_private_message(options[:username], options[:subject], options[:content])
        end
      end

      def reply(original_message, content)
        if original_message.platform_data[:type] == 'comment'
          send_message(
            type: 'reply',
            comment_id: original_message.platform_data[:comment_id],
            content: content
          )
        elsif original_message.platform_data[:type] == 'submission'
          send_message(
            type: 'comment',
            submission_id: original_message.platform_data[:submission_id],
            content: content
          )
        end
      end

      def format_response(response)
        # Reddit markdown formatting
        # - Support for **bold**, *italic*, `code`
        # - Link formatting
        # - Line breaks
        
        # Ensure proper markdown formatting
        response = response.gsub(/\n\n+/, "\n\n")  # Clean up extra line breaks
        
        # Add proper citation format for Reddit
        if response.length > 1000
          response = response[0..996] + "...\n\n*[Response truncated]*"
        end
        
        # Add bot signature
        response += "\n\n---\n*I'm an AI assistant. [Learn more](https://example.com/ai3)*"
        
        response
      end

      def should_respond?(message)
        content = message.content.downcase
        
        # Respond to mentions
        return true if content.include?('/u/ai3bot') || content.include?('u/ai3bot')
        
        # Respond to specific keywords in monitored subreddits
        subreddit = message.platform_data[:subreddit]
        
        case subreddit
        when 'programming', 'learnprogramming'
          return true if content.match?(/\b(help|question|bug|error|code)\b/)
        when 'AskReddit'
          return true if content.match?(/\b(ai|artificial intelligence|bot)\b/)
        when 'technology'
          return true if content.match?(/\b(ai|machine learning|automation)\b/)
        end
        
        # Respond to direct messages
        message.is_direct_message?
      end

      def disconnect
        @monitoring = false
        @connected = false
        puts "Disconnected from Reddit"
      end

      private

      def setup_reddit_client
        # Placeholder for Reddit API client setup
        # In a real implementation, this would use a Ruby Reddit gem like 'redd'
        puts "Setting up Reddit API client"
      end

      def start_monitoring
        @monitoring = true
        
        Thread.new do
          while @monitoring
            @subreddits.each do |subreddit|
              monitor_subreddit(subreddit)
            end
            sleep(30)  # Rate limiting
          end
        end
      end

      def monitor_subreddit(subreddit)
        return unless @monitoring
        
        begin
          # Monitor new submissions
          monitor_new_submissions(subreddit)
          
          # Monitor new comments
          monitor_new_comments(subreddit)
          
        rescue => e
          puts "Error monitoring r/#{subreddit}: #{e.message}"
        end
      end

      def monitor_new_submissions(subreddit)
        # Fetch new submissions from subreddit
        submissions = fetch_new_submissions(subreddit)
        
        submissions.each do |submission|
          message = create_submission_message(submission, subreddit)
          @message_handler&.call(message) if should_process_submission?(submission)
        end
      end

      def monitor_new_comments(subreddit)
        # Fetch new comments from subreddit
        comments = fetch_new_comments(subreddit)
        
        comments.each do |comment|
          message = create_comment_message(comment, subreddit)
          @message_handler&.call(message) if should_process_comment?(comment)
        end
      end

      def fetch_new_submissions(subreddit)
        # Placeholder for Reddit API call
        # Would fetch from Reddit API: /r/subreddit/new.json
        []
      end

      def fetch_new_comments(subreddit)
        # Placeholder for Reddit API call
        # Would fetch from Reddit API: /r/subreddit/comments.json
        []
      end

      def create_submission_message(submission, subreddit)
        AI3::Message.new(
          content: "#{submission['title']}\n\n#{submission['selftext']}",
          user_id: submission['author'],
          channel: "r/#{subreddit}",
          timestamp: Time.at(submission['created_utc']),
          platform_data: {
            from_bot: submission['author'] == @username,
            mentions_bot: (submission['selftext'] || '').downcase.include?('ai3'),
            direct_message: false,
            type: 'submission',
            subreddit: subreddit,
            submission_id: submission['id'],
            score: submission['score'],
            url: "https://reddit.com#{submission['permalink']}"
          }
        )
      end

      def create_comment_message(comment, subreddit)
        AI3::Message.new(
          content: comment['body'],
          user_id: comment['author'],
          channel: "r/#{subreddit}",
          timestamp: Time.at(comment['created_utc']),
          platform_data: {
            from_bot: comment['author'] == @username,
            mentions_bot: comment['body'].downcase.include?('ai3'),
            direct_message: false,
            type: 'comment',
            subreddit: subreddit,
            comment_id: comment['id'],
            submission_id: comment['link_id'],
            score: comment['score']
          }
        )
      end

      def should_process_submission?(submission)
        # Filter criteria for submissions
        return false if submission['author'] == @username
        return false if submission['created_utc'] < (Time.now - 3600).to_i  # Only last hour
        
        true
      end

      def should_process_comment?(comment)
        # Filter criteria for comments
        return false if comment['author'] == @username
        return false if comment['created_utc'] < (Time.now - 1800).to_i  # Only last 30 minutes
        
        true
      end

      def post_comment(submission_id, content)
        puts "Posting comment on submission #{submission_id}: #{content[0..50]}..."
        # Real implementation would use Reddit API to post comment
      end

      def reply_to_comment(comment_id, content)
        puts "Replying to comment #{comment_id}: #{content[0..50]}..."
        # Real implementation would use Reddit API to reply to comment
      end

      def send_private_message(username, subject, content)
        puts "Sending PM to #{username}: #{subject}"
        # Real implementation would use Reddit API to send private message
      end
    end
  end
end