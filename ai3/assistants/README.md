# AI³ Assistants

This directory contains specialized AI assistant modules for various domains and use cases.

## Available Assistants

### General Purpose
- `healthcare.rb` - Medical and health-related assistance
- `lawyer.rb` - Legal research and advice (Norwegian and international law)
- `architect.rb` - Architecture and design guidance
- `web_developer.rb` - Web development assistance
- `sys_admin.rb` - System administration support

### Technical Specialists  
- `hacker.rb` - Cybersecurity and penetration testing
- `openbsd_driver_translator.rb` - OpenBSD driver development
- `material_science.rb` - Materials engineering and science
- `propulsion_engineer.rb` - Propulsion systems engineering
- `rocket_scientist.rb` - Aerospace and rocket engineering
- `advanced_propulsion.rb` - Advanced propulsion technologies

### Business & Finance
- `trader.rb` - Financial trading and market analysis
- `real_estate.rb` - Real estate investment and management
- `seo.rb` - Search engine optimization
- `influencer.rb` - Social media and influencer marketing

### Security & Safety
- `personal_safety.rb` - Personal security and safety planning
- `neuro_scientist.rb` - Neuroscience research assistance

### Special Operations
- `offensive_operations.rb` - Security operations (see also `offensive_operations.md`)

## Usage

Each assistant can be instantiated and used independently:

```ruby
require_relative 'assistants/lawyer'

lawyer = Assistants::Lawyer.new
response = lawyer.process("What are the requirements for Norwegian employment law?")
puts response
```

## Configuration

Assistants can be configured with specific parameters:

```ruby
# Example: Configure lawyer for specific jurisdiction
lawyer = Assistants::Lawyer.new(
  jurisdiction: 'NO',
  language: 'en',
  specialization: :employment
)
```

## Integration

All assistants integrate with the core AI³ system:
- RAG (Retrieval-Augmented Generation) engine
- Context management
- Memory management  
- Universal scraper for research
- Weaviate vector database

## Adding New Assistants

1. Create new assistant file following the naming convention
2. Implement the standard assistant interface
3. Add appropriate knowledge sources and capabilities
4. Update this README

## Assistant Interface

All assistants should implement:
- `initialize(config = {})` - Setup with configuration
- `process(input, context = {})` - Main processing method
- `capabilities` - List of assistant capabilities
- `name` and `role` - Assistant identification