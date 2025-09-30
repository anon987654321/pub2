# BRGEN.NO - Comprehensive Architecture Plan
**Version**: 1.0.0
**Date**: 2025-09-30
**Status**: Research & Design Phase

---

## Vision

**BRGEN.NO**: Norway's revolutionary multimedia platform combining:
- Social networking (Reddit, X, TikTok, Snapchat)
- Marketplace (Airbnb, Etsy via Solidus)
- Media (SoundCloud, TV channels)
- Dating (Tinder)
- Delivery (DoorDash)
- AI Generation (LangChainRB + Replicate.com)

**Multi-tenant**: Each Norwegian city gets its own subdomain with localized content.

---

## Research Checklist

### Core Rails 8 + Hotwire Stack

- [ ] **Rails 8 Changelog**
  - Source: https://github.com/rails/rails/blob/main/CHANGELOG.md
  - Focus: New features, deprecations, Solid Queue, Solid Cache, Solid Cable
  - Key: Authentication changes, asset pipeline updates

- [ ] **Hotwire (Turbo + Stimulus)**
  - Turbo: https://github.com/hotwired/turbo-rails
  - Stimulus: https://github.com/hotwired/stimulus
  - Key: Turbo 8 features, morphing, page refresh, streams

- [ ] **StimulusReflex**
  - Source: https://github.com/stimulusreflex/stimulus_reflex
  - Docs: https://docs.stimulusreflex.com/
  - Key: Real-time updates, CableReady integration, morphs
  - Note: Check if still maintained or if Turbo 8 supersedes it

- [ ] **Stimulus Components**
  - Source: https://www.stimulus-components.com/
  - Components needed:
    - `stimulus-dropdown` - menus
    - `stimulus-lightbox` - media viewing
    - `stimulus-notification` - alerts
    - `stimulus-scroll-reveal` - infinite scroll
    - `stimulus-textarea-autogrow` - forms
    - `stimulus-character-counter` - post limits
    - `stimulus-clipboard` - sharing
    - `stimulus-sortable` - drag-drop
    - `stimulus-popover` - tooltips

### Authentication & Authorization

- [ ] **Devise**
  - Source: https://github.com/heartcombo/devise
  - Modules: Database Authenticatable, Recoverable, Rememberable, Validatable, Trackable, Omniauthable
  - Rails 8 compatibility check

- [ ] **Devise Guests**
  - Source: https://github.com/cbeer/devise-guests
  - Purpose: Anonymous posting without signup
  - Integration: Guest-to-user conversion flow

- [ ] **OmniAuth Vipps**
  - Source: https://github.com/vippsas/omniauth-vipps (if exists, else custom)
  - Docs: https://developer.vipps.no/
  - Key: OAuth2 flow, user data mapping, Norwegian citizens

- [ ] **OmniAuth BankID**
  - Source: https://github.com/bankid-norway/omniauth-bankid (if exists)
  - Docs: https://www.bankid.no/en/developer/
  - Key: Strong authentication, identity verification

- [ ] **Pundit or CanCanCan**
  - Authorization layer for multi-tenant permissions
  - Per-city moderators, admin roles

### Multi-Tenancy

- [ ] **ActsAsTenant**
  - Source: https://github.com/ErwinM/acts_as_tenant
  - Current approach in brgen.sh
  - Key: Row-level tenancy, subdomain routing

- [ ] **Apartment Gem** (alternative)
  - Source: https://github.com/influitive/apartment
  - Key: Schema-based tenancy (if needed for isolation)

- [ ] **Domain Routing**
  - Rails routes constraint by subdomain
  - City model with subdomain field
  - Fallback to main brgen.no

### Marketplace (Solidus)

- [ ] **Solidus Edge Guides**
  - Source: https://edgeguides.solidus.io/
  - Key sections:
    - Getting Started
    - Products & Variants
    - Orders & Payments
    - Shipping & Fulfillment
    - Multi-Store (for multi-tenancy)
    - Extensions ecosystem

- [ ] **Solidus GitHub**
  - Source: https://github.com/solidusio/solidus
  - Latest stable: Check for Rails 8 compatibility
  - Extensions: solidus_stripe, solidus_klarna (for Norway)

- [ ] **Integration Pattern**
  - Mount Solidus at `/marketplace` subdomain route
  - Share User model with main app
  - Tenant-specific product catalogs
  - Norwegian payment providers: Vipps, Klarna, Stripe

### AI & Media Generation

- [ ] **LangChainRB**
  - Source: https://github.com/patterns-ai-core/langchainrb
  - Docs: Check README, examples folder
  - Key: LLM chains, prompts, agents, vector stores

- [ ] **LangChainRB CLI**
  - Source: https://github.com/patterns-ai-core/langchainrb-cli (if exists)
  - Purpose: Code generation, scaffolding

- [ ] **Vector DB Examples**
  - Pinecone: https://github.com/pinecone-io/pinecone-ruby-client
  - Weaviate: https://github.com/weaviate/weaviate-ruby-client
  - Qdrant: https://github.com/qdrant/qdrant-ruby
  - pgvector: PostgreSQL extension for embeddings

- [ ] **Replicate.com Integration**
  - API: https://replicate.com/docs/reference/http
  - Ruby client: https://github.com/replicate/replicate-ruby
  - Models:
    - Stable Diffusion XL - image generation
    - Whisper - audio transcription
    - SDXL-Lightning - fast image gen
    - MusicGen - music generation
    - Video generation models

### Media Stack

- [ ] **Active Storage**
  - Direct uploads to S3/Spaces
  - Video processing: ffmpeg
  - Image variants: libvips
  - Streaming: HLS transcoding

- [ ] **ActionCable**
  - Real-time chat
  - Live video streams
  - Presence channels
  - Notifications

- [ ] **Media Processing**
  - ffmpeg: video/audio
  - ImageMagick/libvips: images
  - Background jobs: Solid Queue or Sidekiq

### OpenBSD Integration

- [ ] **Link with pub2/openbsd.sh**
  - Deploy script integration
  - Port assignments (brgen:10001)
  - Database setup automation
  - SSL cert management
  - Falcon server config

- [ ] **Service Architecture**
  - relayd: Load balancing, TLS termination
  - PostgreSQL: Main database + pgvector
  - Redis: Cache, ActionCable, Solid Queue
  - NSD: DNS with DNSSEC
  - Falcon: Async HTTP server

---

## Proposed Architecture

### 1. Application Structure

```
brgen.no/
├── app/
│   ├── models/
│   │   ├── city.rb                    # Tenant model
│   │   ├── user.rb                    # Devise + OmniAuth
│   │   ├── guest_user.rb              # Devise Guests
│   │   ├── post.rb                    # Social posts
│   │   ├── media_item.rb              # Images/videos/audio
│   │   ├── ai_generation.rb           # LangChain jobs
│   │   ├── listing.rb                 # Marketplace items
│   │   ├── conversation.rb            # Dating/messages
│   │   └── concerns/
│   │       └── tenant_scoped.rb       # ActsAsTenant concern
│   ├── controllers/
│   │   ├── application_controller.rb  # Tenant setup
│   │   ├── social/                    # Reddit/X-like
│   │   ├── marketplace/               # Solidus mount
│   │   ├── media/                     # SoundCloud/TikTok
│   │   ├── dating/                    # Tinder-like
│   │   ├── delivery/                  # DoorDash-like
│   │   └── ai/                        # Generation endpoints
│   ├── javascript/
│   │   ├── controllers/               # Stimulus
│   │   └── channels/                  # ActionCable
│   ├── reflexes/                      # StimulusReflex
│   └── views/
├── db/
│   ├── schema.rb
│   └── migrate/
├── config/
│   ├── routes.rb                      # Subdomain routing
│   ├── initializers/
│   │   ├── devise.rb
│   │   ├── omniauth.rb
│   │   ├── langchain.rb
│   │   └── replicate.rb
│   └── locales/
│       ├── no.yml                     # Norwegian
│       ├── en.yml                     # English fallback
│       └── nn.yml                     # Nynorsk
└── solidus/                           # Solidus integration
```

### 2. Multi-Tenancy Pattern

```ruby
# app/models/city.rb
class City < ApplicationRecord
  has_many :users
  has_many :posts
  has_many :listings

  validates :subdomain, presence: true, uniqueness: true
  validates :name, presence: true
end

# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :set_tenant

  private

  def set_tenant
    subdomain = request.subdomain
    @current_city = City.find_by(subdomain: subdomain)

    if @current_city
      ActsAsTenant.current_tenant = @current_city
    else
      redirect_to root_url(subdomain: false), alert: t("city_not_found")
    end
  end
end

# config/routes.rb
Rails.application.routes.draw do
  constraints subdomain: /.+/ do
    # Tenant-specific routes
    resources :posts
    resources :listings
    namespace :marketplace do
      mount Solidus::Core::Engine, at: "/"
    end
  end

  # Main brgen.no routes
  constraints subdomain: "" do
    root "home#index"
    get "cities", to: "cities#index"
  end
end
```

### 3. Authentication Stack

```ruby
# config/initializers/devise.rb
Devise.setup do |config|
  config.omniauth :vipps,
    ENV["VIPPS_CLIENT_ID"],
    ENV["VIPPS_CLIENT_SECRET"],
    scope: "openid email phone"

  config.omniauth :bankid,
    ENV["BANKID_CLIENT_ID"],
    ENV["BANKID_CLIENT_SECRET"]
end

# app/models/user.rb
class User < ApplicationRecord
  acts_as_tenant :city

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:vipps, :bankid]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.phone = auth.info.phone
    end
  end
end

# Guest users for anonymous posting
# app/models/guest_user.rb
class GuestUser < User
  include DeviseGuests::GuestUser

  def upgrade_to_full_user!(email, password)
    update(
      email: email,
      password: password,
      guest: false
    )
  end
end
```

### 4. AI Generation with LangChainRB

```ruby
# app/services/ai_generation_service.rb
class AiGenerationService
  def initialize(prompt:, type:, user:)
    @prompt = prompt
    @type = type # :image, :video, :audio, :text
    @user = user
  end

  def generate
    case @type
    when :image
      generate_image
    when :video
      generate_video
    when :audio
      generate_audio
    when :text
      generate_text
    end
  end

  private

  def generate_image
    # LangChainRB chain
    llm = Langchain::LLM::Replicate.new(
      api_key: ENV["REPLICATE_API_TOKEN"]
    )

    response = llm.complete(
      prompt: enhance_prompt(@prompt),
      model: "stability-ai/sdxl:latest"
    )

    AiGeneration.create!(
      user: @user,
      prompt: @prompt,
      result_url: response.output,
      generation_type: :image,
      city: ActsAsTenant.current_tenant
    )
  end

  def enhance_prompt(prompt)
    # Use LangChain to enhance prompts
    chain = Langchain::Prompt::PromptTemplate.new(
      template: "Enhance this prompt for image generation: {prompt}",
      input_variables: ["prompt"]
    )

    chain.format(prompt: prompt)
  end
end

# app/jobs/ai_generation_job.rb
class AiGenerationJob < ApplicationJob
  queue_as :ai

  def perform(generation_id)
    generation = AiGeneration.find(generation_id)

    service = AiGenerationService.new(
      prompt: generation.prompt,
      type: generation.generation_type,
      user: generation.user
    )

    result = service.generate

    generation.update!(
      status: :completed,
      result_url: result.url
    )

    # Broadcast via Turbo Stream
    Turbo::StreamsChannel.broadcast_replace_to(
      "ai_generations_#{generation.user_id}",
      target: "generation_#{generation.id}",
      partial: "ai_generations/generation",
      locals: { generation: generation }
    )
  end
end
```

### 5. Real-Time Features

```javascript
// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entries", "pagination"]
  static values = { url: String }

  connect() {
    this.createObserver()
  }

  createObserver() {
    const observer = new IntersectionObserver(
      entries => this.handleIntersect(entries),
      { threshold: 1 }
    )
    observer.observe(this.paginationTarget)
  }

  async handleIntersect(entries) {
    entries.forEach(async entry => {
      if (entry.isIntersecting) {
        const url = this.paginationTarget.dataset.nextPage
        if (url) {
          const response = await fetch(url, {
            headers: { "Accept": "text/vnd.turbo-stream.html" }
          })
          const html = await response.text()
          Turbo.renderStreamMessage(html)
        }
      }
    })
  }
}
```

```ruby
# app/reflexes/post_reflex.rb
class PostReflex < ApplicationReflex
  def upvote
    post = Post.find(element.dataset.post_id)
    post.increment!(:upvotes)

    morph "#post_#{post.id}_votes", render(
      partial: "posts/votes",
      locals: { post: post }
    )
  end

  def comment
    post = Post.find(element.dataset.post_id)
    content = element.value

    comment = post.comments.create!(
      content: content,
      user: current_user
    )

    cable_ready
      .prepend(
        selector: "#post_#{post.id}_comments",
        html: render(partial: "comments/comment", locals: { comment: comment })
      )
      .clear(selector: element.selector)
      .broadcast
  end
end
```

### 6. Vector Search for AI Content

```ruby
# db/migrate/xxx_enable_pgvector.rb
class EnablePgvector < ActiveRecord::Migration[8.0]
  def change
    enable_extension "vector"
  end
end

# db/migrate/xxx_add_embeddings_to_posts.rb
class AddEmbeddingsToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :embedding, :vector, limit: 1536
    add_index :posts, :embedding, using: :ivfflat, opclass: :vector_l2_ops
  end
end

# app/models/post.rb
class Post < ApplicationRecord
  acts_as_tenant :city

  after_save :generate_embedding, if: :content_changed?

  def self.semantic_search(query, limit: 10)
    embedding = OpenAI.new.embeddings(
      parameters: {
        model: "text-embedding-3-small",
        input: query
      }
    ).dig("data", 0, "embedding")

    nearest_neighbors(:embedding, embedding, distance: "cosine")
      .where(city: ActsAsTenant.current_tenant)
      .limit(limit)
  end

  private

  def generate_embedding
    return unless content.present?

    response = OpenAI.new.embeddings(
      parameters: {
        model: "text-embedding-3-small",
        input: content
      }
    )

    self.embedding = response.dig("data", 0, "embedding")
    save
  end
end
```

---

## Implementation Phases

### Phase 1: Foundation (Weeks 1-2)
- [ ] Set up Rails 8 with Hotwire
- [ ] Multi-tenancy with ActsAsTenant
- [ ] Devise + OmniAuth (Vipps/BankID)
- [ ] Basic City/User/Post models
- [ ] Subdomain routing
- [ ] OpenBSD deployment script integration

### Phase 2: Social Features (Weeks 3-4)
- [ ] Reddit-like posts with voting
- [ ] X-like following system
- [ ] TikTok-like video feed
- [ ] Snapchat-like stories
- [ ] Real-time notifications
- [ ] Infinite scroll

### Phase 3: Marketplace (Weeks 5-6)
- [ ] Solidus integration
- [ ] Product listings per city
- [ ] Norwegian payment providers
- [ ] Airbnb-like bookings
- [ ] DoorDash-like delivery

### Phase 4: Dating & Messaging (Week 7)
- [ ] Tinder-like swipe interface
- [ ] Private messaging
- [ ] Video calls (WebRTC)
- [ ] Match algorithm

### Phase 5: Media & AI (Weeks 8-10)
- [ ] SoundCloud-like audio streaming
- [ ] TV channel infrastructure
- [ ] LangChainRB integration
- [ ] Replicate.com models
- [ ] Vector search
- [ ] AI generation UI

### Phase 6: Polish & Launch (Weeks 11-12)
- [ ] Performance optimization
- [ ] Security audit
- [ ] Norwegian localization
- [ ] Mobile PWA
- [ ] Production deployment

---

## Next Steps

1. **Create research agent tasks** for each source
2. **Prototype multi-tenant routing** with 2-3 cities
3. **Test Vipps/BankID OAuth** in sandbox
4. **Solidus proof-of-concept** with Norwegian payments
5. **LangChainRB + Replicate** image generation demo
6. **OpenBSD deployment** dry run

---

## Questions to Answer

1. **StimulusReflex vs Turbo 8**: Which for real-time? Or both?
2. **Schema vs Row tenancy**: ActsAsTenant sufficient or need Apartment?
3. **Solidus Rails 8**: Compatibility status?
4. **Vipps OAuth**: Official gem or custom implementation?
5. **BankID**: API access requirements for testing?
6. **Vector DB**: pgvector sufficient or need dedicated (Pinecone/Qdrant)?
7. **Media storage**: OpenBSD local or S3/Spaces?
8. **WebRTC**: Self-hosted or service (Twilio)?

---

**Status**: Ready for systematic research phase using Task agents.

**Evidence Required**:
- Source code analysis for each component
- Rails 8 compatibility matrix
- Norwegian OAuth provider integration guides
- Multi-tenancy performance benchmarks
- AI generation cost projections

**Next Action**: Create Task agent prompts for parallel research of all sources.