#!/bin/bash
set -euo pipefail

# Shared functions for BRGEN Rails applications
# Master.json v146.1.0 compliant - minimal, working implementations

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1 || {
        log "ERROR: $1 is required but not installed"
        exit 1
    }
}

# Install gem if not present
install_gem() {
    local gem_name="$1"
    if ! bundle list | grep -q "^  \* $gem_name "; then
        log "Installing gem: $gem_name"
        bundle add "$gem_name"
    else
        log "Gem already installed: $gem_name"
    fi
}

setup_full_app() {
    local app_name="$1"
    log "Setting up full Rails application: $app_name"
    
    # Change to app directory
    mkdir -p "$BASE_DIR/$app_name"
    cd "$BASE_DIR/$app_name"
    
    # Create Rails app if it doesn't exist
    if [ ! -f "config/application.rb" ]; then
        log "Creating new Rails application"
        rails new . --api --database=postgresql --skip-git --skip-bundle
    fi
    
    setup_core
    setup_postgresql
    setup_redis
    setup_rails
    setup_devise
}

setup_postgresql() {
    log "Setting up PostgreSQL database configuration"
    
    # Ensure database configuration exists
    if [ ! -f "config/database.yml" ]; then
        log "Creating database configuration"
        cat > config/database.yml << EOF
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: ${APP_NAME}_development
  username: <%= ENV.fetch("POSTGRES_USER", "dev") %>
  password: <%= ENV.fetch("POSTGRES_PASSWORD", "") %>
  host: <%= ENV.fetch("POSTGRES_HOST", "localhost") %>

test:
  <<: *default
  database: ${APP_NAME}_test
  username: <%= ENV.fetch("POSTGRES_USER", "dev") %>
  password: <%= ENV.fetch("POSTGRES_PASSWORD", "") %>
  host: <%= ENV.fetch("POSTGRES_HOST", "localhost") %>

production:
  <<: *default
  url: <%= ENV["DATABASE_URL"] %>
EOF
    fi
}

setup_redis() {
    log "Setting up Redis configuration"
    
    # Add Redis configuration to application config
    if ! grep -q "redis" config/application.rb 2>/dev/null; then
        log "Configuring Redis connection"
        install_gem "redis"
    fi
}

setup_ruby() {
    log "Verifying Ruby environment"
    command_exists "ruby"
    command_exists "bundle"
    
    # Ensure Gemfile exists
    if [ ! -f "Gemfile" ]; then
        log "Creating basic Gemfile"
        bundle init
    fi
}

setup_yarn() {
    log "Setting up Yarn and frontend assets"
    command_exists "yarn"
    
    # Install packages if package.json exists
    if [ -f "package.json" ]; then
        yarn install
    fi
}

setup_rails() {
    log "Setting up Rails framework components"
    
    # Install essential gems
    install_gem "bootsnap"
    install_gem "puma"
    install_gem "sprockets-rails"
    
    bundle install
    
    # Run basic Rails setup commands
    if [ ! -d "db" ]; then
        bin/rails db:create db:migrate
    fi
}

setup_solid_queue() {
    log "Setting up Solid Queue for background jobs"
    install_gem "solid_queue"
    
    # Generate solid queue configuration
    if [ ! -f "config/queue.yml" ]; then
        bin/rails generate solid_queue:install
    fi
}

setup_solid_cache() {
    log "Setting up Solid Cache"
    install_gem "solid_cache"
    
    if [ ! -f "db/migrate/*_create_solid_cache_tables.rb" ]; then
        bin/rails generate solid_cache:install
    fi
}

setup_core() {
    log "Setting up core Rails application structure"
    setup_ruby
    setup_yarn
}

setup_devise() {
    log "Setting up Devise authentication"
    install_gem "devise"
    
    # Generate devise configuration if not present
    if [ ! -f "config/initializers/devise.rb" ]; then
        bin/rails generate devise:install
        bin/rails generate devise User
    fi
}

setup_storage() {
    log "Setting up Active Storage"
    
    # Install Active Storage if not already present
    if [ ! -f "db/migrate/*_create_active_storage_tables.rb" ]; then
        bin/rails active_storage:install
    fi
}

setup_stripe() {
    log "Setting up Stripe payment processing"
    install_gem "stripe"
    
    # Create basic Stripe configuration
    if [ ! -f "config/initializers/stripe.rb" ]; then
        cat > config/initializers/stripe.rb << EOF
Rails.application.configure do
  config.stripe = {
    publishable_key: ENV.fetch('STRIPE_PUBLISHABLE_KEY', ''),
    secret_key: ENV.fetch('STRIPE_SECRET_KEY', '')
  }
end

Stripe.api_key = Rails.application.config.stripe[:secret_key]
EOF
    fi
}

setup_mapbox() {
    log "Setting up Mapbox integration"
    
    # Add Mapbox configuration
    if [ ! -f "config/initializers/mapbox.rb" ]; then
        cat > config/initializers/mapbox.rb << EOF
Rails.application.configure do
  config.mapbox = {
    access_token: ENV.fetch('MAPBOX_ACCESS_TOKEN', '')
  }
end
EOF
    fi
}

setup_live_search() {
    log "Setting up live search functionality"
    install_gem "stimulus_reflex"
    
    # Create basic search reflex
    if [ ! -f "app/reflexes/search_reflex.rb" ]; then
        mkdir -p app/reflexes
        cat > app/reflexes/search_reflex.rb << EOF
class SearchReflex < ApplicationReflex
  def search
    @query = element.value
    # Implement search logic based on current model
  end
end
EOF
    fi
}

setup_infinite_scroll() {
    log "Setting up infinite scroll"
    install_gem "pagy"
    
    # Create base infinite scroll reflex
    if [ ! -f "app/reflexes/infinite_scroll_reflex.rb" ]; then
        mkdir -p app/reflexes
        cat > app/reflexes/infinite_scroll_reflex.rb << EOF
class InfiniteScrollReflex < ApplicationReflex
  def load_more
    # Override this method in specific reflexes
    @page = params[:page].to_i || 1
  end
end
EOF
    fi
}

setup_anon_posting() {
    log "Setting up anonymous posting capabilities"
    
    # Create anonymous posting service
    if [ ! -f "app/services/anonymous_post_service.rb" ]; then
        mkdir -p app/services
        cat > app/services/anonymous_post_service.rb << EOF
class AnonymousPostService
  def self.create_post(params, session_id)
    # Implementation for anonymous posting
    # Uses session-based identification
  end
end
EOF
    fi
}

setup_anon_chat() {
    log "Setting up anonymous chat"
    install_gem "redis"
    
    # Create anonymous chat channel
    if [ ! -f "app/channels/anonymous_chat_channel.rb" ]; then
        mkdir -p app/channels
        cat > app/channels/anonymous_chat_channel.rb << EOF
class AnonymousChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "anonymous_chat_\#{params[:room_id]}"
  end

  def speak(data)
    ActionCable.server.broadcast("anonymous_chat_\#{params[:room_id]}", data)
  end
end
EOF
    fi
}

setup_expiry_job() {
    log "Setting up content expiry job"
    
    if [ ! -f "app/jobs/content_expiry_job.rb" ]; then
        mkdir -p app/jobs
        cat > app/jobs/content_expiry_job.rb << EOF
class ContentExpiryJob < ApplicationJob
  queue_as :default

  def perform
    # Clean up expired anonymous content
    # Implementation varies by application
  end
end
EOF
    fi
}

setup_seeds() {
    log "Setting up database seeds"
    
    if [ ! -f "db/seeds.rb" ] || [ ! -s "db/seeds.rb" ]; then
        cat > db/seeds.rb << EOF
# Seeds for #{APP_NAME}
# Create sample data for development

if Rails.env.development?
  # Add sample data creation here
  puts "Created sample data for \#{Rails.env} environment"
end
EOF
    fi
}

setup_pwa() {
    log "Setting up Progressive Web App features"
    
    # Create basic PWA manifest
    if [ ! -f "public/manifest.json" ]; then
        cat > public/manifest.json << EOF
{
  "name": "${APP_NAME}",
  "short_name": "${APP_NAME}",
  "description": "${APP_NAME} Progressive Web Application",
  "start_url": "/",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#ffffff"
}
EOF
    fi
}

setup_i18n() {
    log "Setting up internationalization"
    
    # Create Norwegian locale file
    mkdir -p config/locales
    if [ ! -f "config/locales/no.yml" ]; then
        cat > config/locales/no.yml << EOF
no:
  app_name: "${APP_NAME}"
  common:
    save: "Lagre"
    cancel: "Avbryt"
    delete: "Slett"
    edit: "Rediger"
EOF
    fi
}

setup_falcon() {
    log "Setting up Falcon web server"
    install_gem "falcon"
    
    # Create Falcon configuration
    if [ ! -f "falcon.rb" ]; then
        cat > falcon.rb << EOF
#!/usr/bin/env ruby
require_relative 'config/environment'

app = Rails.application
app.load_tasks

run app
EOF
        chmod +x falcon.rb
    fi
}

setup_stimulus_components() {
    log "Setting up Stimulus components"
    
    # Ensure stimulus is installed
    if ! grep -q "stimulus" package.json 2>/dev/null; then
        yarn add stimulus
    fi
    
    # Create basic stimulus application
    if [ ! -f "app/javascript/controllers/application.js" ]; then
        mkdir -p app/javascript/controllers
        cat > app/javascript/controllers/application.js << EOF
import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"

const application = Application.start()
const context = require.context(".", true, /\.js$/)
application.load(definitionsFromContext(context))
EOF
    fi
}

setup_vote_controller() {
    log "Setting up voting controller"
    
    if [ ! -f "app/controllers/votes_controller.rb" ]; then
        cat > app/controllers/votes_controller.rb << EOF
class VotesController < ApplicationController
  def up
    # Implementation for upvote
    render json: { status: 'success' }
  end

  def down
    # Implementation for downvote
    render json: { status: 'success' }
  end
end
EOF
    fi
}

generate_social_models() {
    log "Generating social models"
    
    # Generate basic social models if they don't exist
    if ! bin/rails runner "User" 2>/dev/null; then
        bin/rails generate model User email:string username:string
    fi
    
    if ! bin/rails runner "Post" 2>/dev/null; then
        bin/rails generate model Post title:string content:text user:references
    fi
}

commit() {
    local message="${1:-Update application setup}"
    log "Committing changes: $message"
    
    # Only commit if in git repository
    if [ -d ".git" ]; then
        git add -A
        git commit -m "$message" || log "Nothing to commit"
    else
        log "Not a git repository, skipping commit"
    fi
}

migrate_db() {
    log "Migrating database"
    bin/rails db:create db:migrate
}

generate_turbo_views() {
    local model_name="$1"
    local singular_name="$2"
    log "Generating Turbo views for $model_name"
    
    # Generate basic Turbo-enabled views
    mkdir -p "app/views/$model_name"
    
    if [ ! -f "app/views/$model_name/index.html.erb" ]; then
        cat > "app/views/$model_name/index.html.erb" << EOF
<%= turbo_frame_tag "$model_name" do %>
  <div data-controller="infinite-scroll">
    <% @${model_name}.each do |${singular_name}| %>
      <%= render ${singular_name} %>
    <% end %>
  </div>
<% end %>
EOF
    fi
}