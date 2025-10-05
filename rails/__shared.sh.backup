#!/usr/bin/env zsh
set -euo pipefail

# Shared functions for Rails applications

# Logging function
log() {
    print "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1 || {
        log "ERROR: $1 is required but not installed"
        exit 1
    }
}

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

setup_infinite_scroll_reflex() {
    log "Setting up InfiniteScrollReflex (Julian Rubisch pattern)"
    
    mkdir -p app/reflexes
    if [ ! -f "app/reflexes/infinite_scroll_reflex.rb" ]; then
        cat > app/reflexes/infinite_scroll_reflex.rb << 'INFINITEOF'
class InfiniteScrollReflex < ApplicationReflex
  include Pagy::Backend
  attr_reader :collection

  def load_more
    cable_ready.insert_adjacent_html(
      selector: selector,
      html: render(collection),
      position: position
    )
    cable_ready.broadcast
  end

  def page
    element.dataset.next_page
  end

  def position
    "beforebegin"
  end

  def selector
    raise NotImplementedError, "Override selector in subclass"
  end
end
INFINITEOF
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
# Parameterized code generators to reduce duplication
generate_infinite_scroll_reflex() {
    local model_class="$1"
    local model_plural="${2:-$(echo "$model_class" | awk '{print tolower($0) "s"}')}"
    log "Generating infinite scroll reflex for $model_class"
    
    mkdir -p app/reflexes
    cat > "app/reflexes/${model_plural}_infinite_scroll_reflex.rb" << EOF
class ${model_class}sInfiniteScrollReflex < InfiniteScrollReflex
  def load_more
    @pagy, @collection = pagy(${model_class}.where(community: ActsAsTenant.current_tenant).order(created_at: :desc), page: page)
    super
  end
end
EOF
}

generate_mapbox_controller() {
    local controller_name="$1"
    local center_lng="${2:-5.3467}"
    local center_lat="${3:-60.3971}"
    local model_plural="${4:-listings}"
    log "Generating Mapbox controller: $controller_name"
    
    mkdir -p app/javascript/controllers
    cat > "app/javascript/controllers/${controller_name}_controller.js" << EOF
import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"
import MapboxGeocoder from "mapbox-gl-geocoder"

export default class extends Controller {
  static values = { apiKey: String, ${model_plural}: Array }

  connect() {
    mapboxgl.accessToken = this.apiKeyValue
    this.map = new mapboxgl.Map({
      container: this.element,
      style: "mapbox://styles/mapbox/streets-v11",
      center: [${center_lng}, ${center_lat}],
      zoom: 12
    })

    this.map.addControl(new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      mapboxgl: mapboxgl
    }))

    this.map.on("load", () => {
      this.addMarkers()
    })
  }

  addMarkers() {
    this.${model_plural}Value.forEach(item => {
      new mapboxgl.Marker({ color: "#1a73e8" })
        .setLngLat([item.lng, item.lat])
        .setPopup(new mapboxgl.Popup().setHTML(\`<h3>\${item.title}</h3><p>\${item.description}</p>\`))
        .addTo(this.map)
    })
  }
}
EOF
}

generate_insights_controller() {
    local output_target="${1:-insights-output}"
    log "Generating insights Stimulus controller"
    
    mkdir -p app/javascript/controllers
    cat > app/javascript/controllers/insights_controller.js << EOF
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["output"]

  analyze(event) {
    event.preventDefault()
    if (!this.hasOutputTarget) {
      console.error("InsightsController: Output target not found")
      return
    }
    this.outputTarget.innerHTML = "<i class='fas fa-spinner fa-spin' aria-label='Analyzing'></i>"
    this.stimulate("InsightsReflex#analyze")
  }
}
EOF
}

setup_stimulus_reflex() {
    log "Setting up StimulusReflex and CableReady"
    install_gem "stimulus_reflex"
    install_gem "cable_ready"
    
    if [ ! -f "app/reflexes/application_reflex.rb" ]; then
        bin/rails generate stimulus_reflex:install
    fi
}

setup_filterable_reflex() {
    log "Setting up FilterableReflex (Julian Rubisch pattern)"
    
    mkdir -p app/reflexes app/controllers/concerns app/filters
    
    if [ ! -f "app/reflexes/filter_reflex.rb" ]; then
        cat > app/reflexes/filter_reflex.rb << 'FILTEREOF'
class FilterReflex < ApplicationReflex
  include Filterable
  
  def filter
    resource, param = element.dataset.to_h.fetch_values(:resource, :param)
    value = if element["type"] == "checkbox"
      element.checked
    else 
      element.dataset.value || element.value
    end

    set_filter_for!(resource, param, value)
  end  
end
FILTEREOF
    fi
    
    if [ ! -f "app/controllers/concerns/filterable.rb" ]; then
        cat > app/controllers/concerns/filterable.rb << 'CONCERNEOF'
module Filterable
  extend ActiveSupport::Concern

  included do
    if respond_to?(:helper_method)
      helper_method :filter_active_for?
      helper_method :filter_for
    end
  end

  def filter_active_for?(resource, attribute, value = true)
    filter = filter_for(resource)
    filter.active_for?(attribute, value)
  end

  private

  def filter_for(resource)
    "#{resource}Filter".constantize.new(session)
  end

  def set_filter_for!(resource, param, value)
    filter_for(resource).merge!(param, value)
  end
end
CONCERNEOF
    fi
}

setup_template_reflex() {
    log "Setting up TemplateReflex for dynamic UI composition (Julian Rubisch pattern)"
    
    mkdir -p app/reflexes
    if [ ! -f "app/reflexes/template_reflex.rb" ]; then
        cat > app/reflexes/template_reflex.rb << 'TEMPLATEEOF'
class TemplateReflex < ApplicationReflex
  def insert
    templates << new_template
    morph :nothing
  end

  def remove(uuid = element.dataset.uuid)
    templates.delete_if { |template| template.uuid == uuid }
    morph :nothing
  end

  private

  def templates
    session[:templates] ||= []
  end

  def new_template
    OpenStruct.new(uuid: SecureRandom.urlsafe_base64)
  end
end
TEMPLATEEOF
    fi
}

generate_model_reflex() {
    local model_class="$1"
    local model_plural="${2:-$(echo "$model_class" | awk '{print tolower($0) "s"}')}"
    local tenant_scope="${3:-}"
    
    log "Generating ${model_class} infinite scroll reflex"
    
    mkdir -p app/reflexes
    local scope_clause=""
    if [ -n "$tenant_scope" ]; then
        scope_clause=".where(${tenant_scope})"
    fi
    
    cat > "app/reflexes/${model_plural}_infinite_scroll_reflex.rb" << EOF
class ${model_class}sInfiniteScrollReflex < InfiniteScrollReflex
  def load_more
    @pagy, @collection = pagy(
      ${model_class}${scope_clause}.order(created_at: :desc),
      page: page
    )
    super
  end

  def selector
    "#sentinel"
  end
end
EOF
}

install_yarn_package() {
    local package_name="$1"
    if ! grep -q "\"$package_name\"" package.json 2>/dev/null; then
        log "Installing yarn package: $package_name"
        yarn add "$package_name"
    else
        log "Yarn package already installed: $package_name"
    fi
}

setup_stimulus_use() {
    log "Setting up stimulus-use for IntersectionObserver and other helpers"
    install_yarn_package "stimulus-use"
}

generate_character_counter_controller() {
    log "Generating character counter Stimulus controller"
    mkdir -p app/javascript/controllers
    cat > app/javascript/controllers/character_counter_controller.js << 'CHAREOF'
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "output"]
  static values = { max: { type: Number, default: 500 } }

  connect() {
    this.update()
  }

  update() {
    const length = this.inputTarget.value.length
    const remaining = this.maxValue - length
    this.outputTarget.textContent = `${remaining} characters remaining`
    
    if (remaining < 0) {
      this.outputTarget.classList.add("text-red-600")
    } else {
      this.outputTarget.classList.remove("text-red-600")
    }
  }
}
CHAREOF
}

generate_form_validation_controller() {
    log "Generating form validation Stimulus controller"
    mkdir -p app/javascript/controllers
    cat > app/javascript/controllers/form_validation_controller.js << 'FORMEOF'
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.element.addEventListener("input", () => this.validate())
    this.validate()
  }

  validate() {
    const isValid = this.element.checkValidity()
    
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !isValid
    }
  }

  submit(event) {
    if (!this.element.checkValidity()) {
      event.preventDefault()
      event.stopPropagation()
      
      // Show validation messages
      const firstInvalid = this.element.querySelector(":invalid")
      if (firstInvalid) {
        firstInvalid.focus()
        firstInvalid.reportValidity()
      }
    }
  }
}
FORMEOF
}

generate_infinite_scroll_controller() {
    log "Generating infinite scroll Stimulus controller (Rails 8 + Turbo)"
    mkdir -p app/javascript/controllers
    cat > app/javascript/controllers/infinite_scroll_controller.js << 'SCROLLEOF'
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sentinel"]
  static values = { 
    url: String,
    page: { type: Number, default: 1 }
  }

  connect() {
    this.observer = new IntersectionObserver(
      entries => this.handleIntersect(entries),
      { threshold: 0.1 }
    )
    
    if (this.hasSentinelTarget) {
      this.observer.observe(this.sentinelTarget)
    }
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  async handleIntersect(entries) {
    entries.forEach(async entry => {
      if (entry.isIntersecting && !this.loading) {
        this.loading = true
        this.pageValue++
        
        const url = new URL(this.urlValue, window.location.origin)
        url.searchParams.set('page', this.pageValue)
        
        try {
          const response = await fetch(url, {
            headers: { 
              "Accept": "text/vnd.turbo-stream.html",
              "Turbo-Frame": this.element.id
            }
          })
          
          if (response.ok) {
            const html = await response.text()
            Turbo.renderStreamMessage(html)
          }
        } catch (error) {
          console.error("Infinite scroll error:", error)
        } finally {
          this.loading = false
        }
      }
    })
  }
}
SCROLLEOF
}

generate_dropdown_controller() {
    log "Generating dropdown Stimulus controller"
    mkdir -p app/javascript/controllers
    cat > app/javascript/controllers/dropdown_controller.js << 'DROPEOF'
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle("hidden")
  }

  hide(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
    }
  }

  connect() {
    document.addEventListener("click", this.hide.bind(this))
  }

  disconnect() {
    document.removeEventListener("click", this.hide.bind(this))
  }
}
DROPEOF
}

generate_notification_controller() {
    log "Generating notification Stimulus controller"
    mkdir -p app/javascript/controllers
    cat > app/javascript/controllers/notification_controller.js << 'NOTIFEOF'
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    autoHide: { type: Boolean, default: true },
    delay: { type: Number, default: 5000 }
  }

  connect() {
    if (this.autoHideValue) {
      this.timeout = setTimeout(() => {
        this.hide()
      }, this.delayValue)
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  hide() {
    this.element.classList.add("opacity-0", "translate-x-full")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
NOTIFEOF
}

generate_all_stimulus_controllers() {
    log "Generating all Stimulus controllers for Rails 8 PWA"
    generate_character_counter_controller
    generate_form_validation_controller  
    generate_infinite_scroll_controller
    generate_dropdown_controller
    generate_notification_controller
    
    log "All Stimulus controllers generated"
}

generate_show_view() {
    local model_singular="$1"
    local model_plural="$2"
    log "Generating show view for $model_singular"
    
    mkdir -p "app/views/${model_plural}"
    cat > "app/views/${model_plural}/show.html.erb" << 'SHOWEOF'
<%= turbo_frame_tag dom_id(@<%= model_singular %>) do %>
  <%= tag.article class: "detail-view", role: "article" do %>
    <%= tag.header do %>
      <%= tag.h1 @<%= model_singular %>.title %>
      <%= tag.div class: "meta" do %>
        <%= tag.span t("brgen.posted_by", user: @<%= model_singular %>.user.email) %>
        <%= tag.span @<%= model_singular %>.created_at.strftime("%Y-%m-%d %H:%M") %>
      <% end %>
    <% end %>

    <%= tag.section class: "content" do %>
      <% if @<%= model_singular %>.photos.attached? %>
        <%= tag.div class: "photos" do %>
          <% @<%= model_singular %>.photos.each do |photo| %>
            <%= image_tag photo, alt: t("brgen.listing_photo", title: @<%= model_singular %>.title) %>
          <% end %>
        <% end %>
      <% end %>

      <%= tag.div class: "description" do %>
        <%= simple_format @<%= model_singular %>.description %>
      <% end %>

      <%= tag.dl class: "attributes" do %>
        <%= tag.dt t("brgen.price") %>
        <%= tag.dd number_to_currency(@<%= model_singular %>.price) %>
        
        <%= tag.dt t("brgen.category") %>
        <%= tag.dd @<%= model_singular %>.category %>
        
        <%= tag.dt t("brgen.location") %>
        <%= tag.dd @<%= model_singular %>.location %>
        
        <%= tag.dt t("brgen.status") %>
        <%= tag.dd @<%= model_singular %>.status %>
      <% end %>
    <% end %>

    <% if @<%= model_singular %>.lat.present? && @<%= model_singular %>.lng.present? %>
      <%= tag.div id: "map", 
                  data: { 
                    controller: "mapbox",
                    mapbox_api_key_value: ENV['MAPBOX_TOKEN'],
                    mapbox_<%= model_plural %>_value: [@<%= model_singular %>].to_json
                  },
                  style: "height: 400px; margin: 2rem 0;" %>
    <% end %>

    <%= render partial: "shared/vote", locals: { votable: @<%= model_singular %> } %>

    <%= tag.footer class: "actions" do %>
      <%= link_to t("brgen.back"), <%= model_plural %>_path, class: "button secondary" %>
      <% if @<%= model_singular %>.user == current_user || current_user&.admin? %>
        <%= link_to t("brgen.edit"), edit_<%= model_singular %>_path(@<%= model_singular %>), class: "button" %>
        <%= button_to t("brgen.delete"), <%= model_singular %>_path(@<%= model_singular %>), 
                      method: :delete, 
                      class: "button danger",
                      data: { turbo_confirm: t("brgen.confirm_delete") } %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
SHOWEOF
    
    # Replace template variables with actual model names
    ruby -i -pe "s/<%= model_singular %>/${model_singular}/g; s/<%= model_plural %>/${model_plural}/g" "app/views/${model_plural}/show.html.erb"
}

generate_new_view() {
    local model_singular="$1"
    local model_plural="$2"
    log "Generating new view for $model_singular"
    
    mkdir -p "app/views/${model_plural}"
    cat > "app/views/${model_plural}/new.html.erb" << 'NEWEOF'
<%= turbo_frame_tag "new_<%= model_singular %>" do %>
  <%= tag.article class: "form-container" do %>
    <%= tag.header do %>
      <%= tag.h1 t("brgen.new_<%= model_singular %>") %>
    <% end %>

    <%= render "form", <%= model_singular %>: @<%= model_singular %> %>

    <%= tag.footer do %>
      <%= link_to t("brgen.cancel"), <%= model_plural %>_path, class: "button secondary" %>
    <% end %>
  <% end %>
<% end %>
NEWEOF

    ruby -i -pe "s/<%= model_singular %>/${model_singular}/g; s/<%= model_plural %>/${model_plural}/g" "app/views/${model_plural}/new.html.erb"
}

generate_edit_view() {
    local model_singular="$1"
    local model_plural="$2"
    log "Generating edit view for $model_singular"
    
    mkdir -p "app/views/${model_plural}"
    cat > "app/views/${model_plural}/edit.html.erb" << 'EDITEOF'
<%= turbo_frame_tag dom_id(@<%= model_singular %>) do %>
  <%= tag.article class: "form-container" do %>
    <%= tag.header do %>
      <%= tag.h1 t("brgen.edit_<%= model_singular %>") %>
    <% end %>

    <%= render "form", <%= model_singular %>: @<%= model_singular %> %>

    <%= tag.footer do %>
      <%= link_to t("brgen.cancel"), <%= model_singular %>_path(@<%= model_singular %>), class: "button secondary" %>
    <% end %>
  <% end %>
<% end %>
EDITEOF

    ruby -i -pe "s/<%= model_singular %>/${model_singular}/g; s/<%= model_plural %>/${model_plural}/g" "app/views/${model_plural}/edit.html.erb"
}

generate_crud_views() {
    local model_singular="$1"
    local model_plural="$2"
    log "Generating all CRUD views for ${model_plural}"
    
    generate_show_view "$model_singular" "$model_plural"
    generate_new_view "$model_singular" "$model_plural"
    generate_edit_view "$model_singular" "$model_plural"
    
    log "CRUD views generated: show, new, edit"
}
