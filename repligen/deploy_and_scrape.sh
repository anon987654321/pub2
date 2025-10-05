#!/bin/bash
# Complete VPS Deployment + Scraping Script
# Password: testing1234@

VPS="root@185.52.176.18"

echo "🚀 Deploying Cinematic Pipeline to VPS"
echo "="*70

# Step 1: Copy all files
echo "📦 Copying files to VPS..."
scp repligen.rb postpro.rb scrape_models.rb scrape_replicate_explore.rb $VPS:/root/

# Step 2: Setup and scrape
echo ""
echo "🔧 Setting up VPS and running scraper..."
ssh $VPS << 'REMOTE'
#!/bin/ksh

echo "✓ Connected to $(hostname)"
echo ""

# Install dependencies
echo "📥 Installing dependencies..."
doas pkg_add vips chromium chromedriver
gem33 install sqlite3 ruby-vips ferrum langchainrb tty-prompt --no-document

# Make executable
chmod +x *.rb

echo ""
echo "="*70
echo "🔍 RUNNING REPLICATE SCRAPER"
echo "="*70
echo ""

# Run the scraper
./scrape_replicate_explore.rb

echo ""
echo "="*70
echo "✅ DEPLOYMENT COMPLETE"
echo "="*70
echo ""
echo "Next steps:"
echo "1. Set API tokens:"
echo "   export REPLICATE_API_TOKEN='your_token'"
echo "   export ANTHROPIC_API_KEY='your_key'"
echo ""
echo "2. Launch repligen:"
echo "   ./repligen.rb"
echo ""
echo "3. Try it:"
echo "   R> use this lora https://replicate.com/anon987654321/ra2 to create a cinematic masterpiece of my girlfriend"
REMOTE

echo ""
echo "🎉 Complete! VPS is ready with scraped model database"
