# AI3 Chatbot Modules

This directory contains chatbot integration modules for various platforms.

## Structure

- `chatbot.rb` - Main chatbot orchestration class
- `modules/` - Platform-specific integration modules

## Supported Platforms

- Discord - Gaming and community chat integration
- Snapchat - Social media and AR-enabled interactions  
- 4chan - Anonymous forum integration
- OnlyFans - Creator platform integration
- Reddit - Social news and discussion platform

## Usage

```ruby
require './chatbot.rb'

# Initialize chatbot for specific platform
bot = AI3::Chatbot.new(platform: :discord, config: config)
bot.start

# Send message
bot.send_message(channel: '#general', content: 'Hello!')

# Handle incoming messages
bot.on_message do |message|
  # Process message with AI3 assistant
  response = assistant.process(message.content)
  bot.reply(message, response)
end
```

## Configuration

Each platform module requires specific configuration:

- API keys and tokens
- Channel/room configurations
- Rate limiting settings
- Content moderation rules

## Security

- All modules implement content filtering
- Rate limiting to prevent spam
- Secure token management
- Privacy-preserving message handling