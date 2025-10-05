#!/usr/bin/env ruby33
# Quick Replicate Model Scraper

require "net/http"
require "json"
require "sqlite3"

puts "🔍 Replicate Model Scraper"
puts "="*60

# Initialize database
db = SQLite3::Database.new("repligen_models.db")
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS models (
    id TEXT PRIMARY KEY,
    type TEXT,
    description TEXT,
    cost REAL,
    documentation TEXT,
    discovered_at INTEGER
  )
SQL

puts "✅ Database: repligen_models.db"

# Fetch from Replicate API
puts "\n📡 Fetching models from Replicate API..."

token = ENV["REPLICATE_API_TOKEN"]
unless token
  puts "❌ REPLICATE_API_TOKEN not set"
  exit 1
end

uri = URI("https://api.replicate.com/v1/collections/text-to-image/models")
req = Net::HTTP::Get.new(uri)
req["Authorization"] = "Token #{token}"

response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(req)
end

if response.code == "200"
  data = JSON.parse(response.body)
  models = data["results"] || []
  
  puts "✅ Fetched #{models.size} models"
  
  models.each do |model|
    id = "#{model['owner']}/#{model['name']}"
    type = model['latest_version']&.dig('model_type') || 'unknown'
    description = model['description'] || ''
    cost = 0.05 # Default
    
    db.execute(<<-SQL, [id, type, description, cost, '', Time.now.to_i])
      INSERT OR REPLACE INTO models (id, type, description, cost, documentation, discovered_at)
      VALUES (?, ?, ?, ?, ?, ?)
    SQL
    
    puts "  ✓ #{id}"
  end
  
  puts "\n✅ Saved #{models.size} models to database"
else
  puts "❌ API error: #{response.code}"
end

db.close
puts "\n🎉 Complete! Database ready at: repligen_models.db"
