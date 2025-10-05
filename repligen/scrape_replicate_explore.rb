#!/usr/bin/env ruby33
# Replicate.com/explore Infinite Scroll Scraper with Ferrum

require "ferrum"
require "sqlite3"
require "json"

puts "🔍 Replicate.com/explore Scraper (Infinite Scroll)"
puts "="*70

# Initialize database
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

puts "✅ Database ready: repligen_models.db"

# Initialize Ferrum browser
puts "🌐 Launching headless browser..."
browser = Ferrum::Browser.new(
  headless: true,
  timeout: 60,
  window_size: [1920, 1080],
  browser_options: { 'no-sandbox': nil }
)

begin
  browser.goto("https://www.replicate.com/explore")
  puts "✅ Loaded: https://www.replicate.com/explore"
  
  sleep 3  # Wait for initial load
  
  discovered = 0
  scroll_count = 0
  max_scrolls = 50  # Adjust for more/less scraping
  
  puts "\n📜 Starting infinite scroll scraping..."
  puts "Target: #{max_scrolls} scrolls (approximately #{max_scrolls * 20} models)"
  puts "-"*70
  
  max_scrolls.times do |i|
    scroll_count += 1
    
    # Scroll to bottom
    browser.execute("window.scrollTo(0, document.body.scrollHeight)")
    sleep 2  # Wait for new content to load
    
    # Extract model cards from page
    html = browser.body
    
    # Parse model data (look for common patterns)
    models = extract_models_from_html(html)
    
    models.each do |model|
      begin
        db.execute(<<-SQL, [
          model[:id],
          model[:name],
          model[:owner],
          model[:description],
          model[:type],
          model[:runs],
          model[:cost],
          model[:url],
          Time.now.to_i
        ])
          INSERT OR REPLACE INTO models 
          (id, name, owner, description, type, runs, cost, url, discovered_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        SQL
        
        discovered += 1
      rescue => e
        # Skip duplicates
      end
    end
    
    print "\rScroll #{scroll_count}/#{max_scrolls} | Discovered: #{discovered} models"
    
    # Check if we've reached the end
    current_height = browser.evaluate("document.body.scrollHeight")
    browser.execute("window.scrollTo(0, document.body.scrollHeight)")
    sleep 1
    new_height = browser.evaluate("document.body.scrollHeight")
    
    break if current_height == new_height  # No more content
  end
  
  puts "\n\n✅ Scraping complete!"
  puts "="*70
  
  # Get final stats
  db.results_as_hash = true
  total = db.execute("SELECT COUNT(*) as count FROM models")[0]["count"]
  by_type = db.execute("SELECT type, COUNT(*) as count FROM models WHERE type IS NOT NULL GROUP BY type ORDER BY count DESC")
  
  puts "📊 Database Statistics:"
  puts "  Total models: #{total}"
  puts "\n  By category:"
  by_type.each do |row|
    puts "    #{row['type']}: #{row['count']}"
  end
  
  puts "\n🎉 Models saved to: repligen_models.db"
  
ensure
  browser.quit
  db.close
end

def extract_models_from_html(html)
  models = []
  
  # Pattern 1: Look for model cards (adjust based on actual HTML structure)
  html.scan(/\/([^\/]+)\/([^\/\s"]+)/) do |owner, name|
    next if owner.length < 3 || name.length < 3
    next if owner =~ /^(explore|models|docs|api|blog)$/
    
    id = "#{owner}/#{name}"
    
    # Try to extract additional info
    description = extract_description(html, id)
    type = infer_type(name, description)
    
    models << {
      id: id,
      name: name,
      owner: owner,
      description: description,
      type: type,
      runs: 0,
      cost: 0.05,  # Default
      url: "https://replicate.com/#{id}"
    }
  end
  
  models.uniq { |m| m[:id] }
end

def extract_description(html, model_id)
  # Try to find description near model ID
  if match = html.match(/#{Regexp.escape(model_id)}.*?<p[^>]*>(.*?)<\/p>/m)
    match[1].gsub(/<[^>]+>/, '').strip[0..200]
  else
    ""
  end
end

def infer_type(name, description)
  combined = "#{name} #{description}".downcase
  
  case combined
  when /text.*image|image.*gen|txt2img|t2i|dalle|stable.*diffusion|flux|sdxl/
    'text-to-image'
  when /image.*video|img2vid|i2v|animate/
    'image-to-video'
  when /video|motion|animate/
    'video'
  when /audio|music|sound|tts|speech/
    'audio'
  when /upscale|super.*res|enhance/
    'upscale'
  when /background|rembg|segment/
    'image-processing'
  when /style|artistic/
    'style-transfer'
  when /face|portrait/
    'face'
  when /lora|train/
    'training'
  else
    'other'
  end
end
