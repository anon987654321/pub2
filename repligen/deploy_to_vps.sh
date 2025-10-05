#!/bin/bash
# VPS Deployment Script for Cinematic Pipeline
# Password: testing1234@

VPS="root@185.52.176.18"

echo "🚀 Deploying to VPS: $VPS"
echo "================================================"

# Step 1: Copy files
echo "📦 Copying files to VPS..."
scp repligen.rb postpro.rb scrape_models.rb $VPS:/root/

# Step 2: SSH and setup
echo "🔧 Setting up on VPS..."
ssh $VPS << 'REMOTE'
  echo "✓ Connected to $(hostname)"
  
  # Install libvips
  echo "📥 Installing libvips..."
  doas pkg_add vips
  
  # Install Ruby gems
  echo "💎 Installing Ruby gems..."
  gem33 install sqlite3 ruby-vips ferrum langchainrb tty-prompt --no-document
  
  # Make scripts executable
  chmod +x repligen.rb postpro.rb scrape_models.rb
  
  echo "✅ Setup complete!"
  echo ""
  echo "Next steps:"
  echo "1. Set API tokens:"
  echo "   export REPLICATE_API_TOKEN='your_token'"
  echo "   export ANTHROPIC_API_KEY='your_key'"
  echo ""
  echo "2. Run scraper:"
  echo "   ./scrape_models.rb"
  echo ""
  echo "3. Launch repligen:"
  echo "   ./repligen.rb"
REMOTE

echo "🎉 Deployment complete!"
