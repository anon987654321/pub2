#!/usr/bin/env zsh

APP="amber"
BASE_DIR="$HOME/rails/$APP"

partials=(
  "@common.sh"
  "@postgresql.sh"
  "@redis.sh"
  "@yarn.sh"
  "@rails_new.sh"
  "@pwa.sh"
  "@active_storage_and_imageprocessing.sh"
  "@devise.sh"
  "@falcon.sh"
  "@ai.sh"
  "@posts_communities_and_comments.sh"
  "@instant_messaging.sh"
  "@live_cam_streaming.sh"
  "@social_sharing.sh"
  "@push_notifications.sh"
)

for partial in "${partials[@]}"; do
  source "../__shared/$partial" "$APP" "$BASE_DIR"
done

# -- GENERATE MODELS --

bin/rails generate scaffold Item title:string content:text color:string size:string material:string texture:string brand:string price:decimal category:string stock_quantity:integer available:boolean sku:string release_date:date season:string times_worn:integer purchase_date:date user:references
bin/rails generate scaffold Outfit name:string description:text image_url:string category:string season:string occasion:string weather_condition:string user:references
bin/rails generate model OrganizationTip title:string content:text category:string embedding:vector{1536}
bin/rails generate model WardrobeAnalytic user:references total_items:integer total_value:decimal most_worn_item_id:integer least_worn_item_id:integer average_cost_per_wear:decimal
install_gem "faker"

bin/rails generate service OutfitGenerator
bin/rails generate service WeatherService
bin/rails generate service ColorHarmonyValidator
bin/rails generate controller Search
bin/rails generate controller Home index
bin/rails generate controller Analytics index

# -- CREATE VIEW DIRECTORIES --

mkdir -p app/views/{home,items,looks,layouts,pages,features,outfits,recommendations,search}

# -- LAYOUT TEMPLATES --

cat <<EOF > app/views/layouts/application.html.erb
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="<%= form_authenticity_token %>">
    <title><%= t("site.title") %></title>
    <%= stylesheet_link_tag "application", media: "all", "data-turbo-track": "reload" %>
    <%= javascript_include_tag "application", "data-turbo-track": "reload" %>
    <%= tag.script(type: "application/ld+json") { render(partial: "shared/jsonld") } %>
  </head>
  <body>
    <%= yield %>
    <%= cable_ready_channel_tag %>
    <%= stimulus_include_tag %>
  </body>
</html>
EOF

cat <<EOF > app/views/home/_header.html.erb
<%= tag.header do %>
  <%= tag.nav do %>
    <%= image_tag("logo.svg", alt: t("brand.logo_alt")) %>
    <%= link_to t("navigation.home"), root_path %>
    <%= link_to t("features.visualize_your_wardrobe"), visualize_your_wardrobe_path %>
    <%= link_to t("features.style_assistant"), style_assistant_path %>
    <%= link_to t("features.mix_match_magic"), mix_match_magic_path %>
    <%= link_to t("features.shop_smarter"), shop_smarter_path %>
    <%= link_to t("navigation.search"), search_path %>
    <%= button_to t("navigation.login"), "#", data: { action: "dialog#open" } %>
    <%= button_to t("navigation.dark_mode"), "#", data: { action: "dark-mode#toggle" } %>
  <% end %>
<% end %>
EOF

cat <<EOF > app/views/home/_footer.html.erb
<%= tag.footer do %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.about_amber") %>
    <%= tag.p t("footer.about_description") %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.explore") %>
    <%= link_to t("footer.special_offers"), "#" %>
    <%= link_to t("footer.ethical_practices"), "#" %>
    <%= link_to t("footer.upcoming_designers"), "#" %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.legal") %>
    <%= link_to t("footer.privacy_policy"), "#" %>
    <%= link_to t("footer.terms_of_service"), "#" %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.contact_us") %>
    <%= tag.p t("footer.contact_info") %>
    <%= link_to t("footer.email_us"), "mailto:info@amber.fashion" %>
  <% end %>
  <%= tag.section do %>
    <%= tag.h3 t("footer.supporting_wildlife") %>
    <%= tag.p t("footer.supporting_wildlife_description") %>
  <% end %>
<% end %>
EOF

# -- SET UP CONTROLLERS AND VIEWS FOR FEATURES --

cat <<EOF > app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    @suggestions = generate_mix_and_match_suggestions(current_user.posts)
  end

  private

  def generate_mix_and_match_suggestions(posts)
    posts.sample(3)
  end
end
EOF

cat <<EOF > app/controllers/features_controller.rb
class FeaturesController < ApplicationController
  before_action :authenticate_user!

  def visualize_your_wardrobe
    @posts = current_user.posts
    # Additional logic for categorizing and organizing clothes
  end

  def style_assistant
    @outfits = current_user.outfits
  end

  def mix_match_magic
    @posts = current_user.posts
    @suggestions = generate_mix_and_match_suggestions(@posts)
  end

  def shop_smarter
    @recommendations = current_user.recommendations
  end

  private

  def generate_mix_and_match_suggestions(posts)
    posts.sample(3)
  end
end
EOF

cat <<EOF > app/controllers/outfits_controller.rb
class OutfitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_outfit, only: [:show, :edit, :update, :destroy]

  def index
    @outfits = current_user.outfits
  end

  def show
  end

  def new
    @outfit = current_user.outfits.build
  end

  def create
    @outfit = current_user.outfits.build(outfit_params)
    if @outfit.save
      redirect_to @outfit, notice: t("outfits.create.success")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @outfit.update(outfit_params)
      redirect_to @outfit, notice: t("outfits.update.success")
    else
      render :edit
    end
  end

  def destroy
    @outfit.destroy
    redirect_to outfits_url, notice: t("outfits.destroy.success")
  end

  private

  def set_outfit
    @outfit = current_user.outfits.find(params[:id])
  end

  def outfit_params
    params.require(:outfit).permit(:name, :description, post_ids: [])
  end
end
EOF

cat <<EOF > app/controllers/recommendations_controller.rb
class RecommendationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_recommendation, only: [:show, :edit, :update, :destroy]

  def index
    @recommendations = current_user.recommendations
  end

  def show
  end

  def new
    @recommendation = current_user.recommendations.build
  end

  def create
    @recommendation = current_user.recommendations.build(recommendation_params)
    if @recommendation.save
      redirect_to @recommendation, notice: t("recommendations.create.success")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @recommendation.update(recommendation_params)
      redirect_to @recommendation, notice: t("recommendations.update.success")
    else
      render :edit
    end
  end

  def destroy
    @recommendation.destroy
    redirect_to recommendations_url, notice: t("recommendations.destroy.success")
  end

  private

  def set_recommendation
    @recommendation = current_user.recommendations.find(params[:id])
  end

  def recommendation_params
    params.require(:recommendation).permit(:post_id, :recommended_by)
  end
end
EOF

cat <<EOF > app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    @query = params[:query]
    @results = if @query.present?
      # Semantic search using embeddings
      Item.semantic_search(@query)
    else
      []
    end
  end
end
EOF

cat <<EOF > app/controllers/analytics_controller.rb
class AnalyticsController < ApplicationController
  before_action :authenticate_user!

  def index
    @analytics = WardrobeAnalytic.find_or_create_by(user: current_user)
    @analytics.calculate! unless @analytics.updated_at > 1.day.ago

    @most_worn = current_user.items.order(times_worn: :desc).limit(5)
    @least_worn = current_user.items.where('times_worn < ?', 3).order(times_worn: :asc).limit(5)
    @seasonal_breakdown = current_user.items.group(:season).count
    @category_breakdown = current_user.items.group(:category).count
  end
end
EOF

# -- SERVICE IMPLEMENTATIONS --

mkdir -p app/services

cat <<EOF > app/services/outfit_generator_service.rb
class OutfitGeneratorService
  def initialize(user, occasion: nil, weather: nil, season: nil)
    @user = user
    @occasion = occasion
    @weather = weather
    @season = season || current_season
  end

  def generate
    items = filter_items
    return nil if items[:tops].empty? || items[:bottoms].empty?

    outfit = {
      top: items[:tops].sample,
      bottom: items[:bottoms].sample,
      shoes: items[:shoes].sample,
      accessories: items[:accessories].sample(2)
    }.compact

    # Validate color harmony
    return generate if !ColorHarmonyValidator.new(outfit.values).valid? && retry_count < 5

    create_outfit(outfit)
  end

  private

  def filter_items
    items = @user.items.where(season: [@season, 'all-season'])
    items = items.joins(:weather_suitability).where(weather_condition: @weather) if @weather

    {
      tops: items.where(category: ['shirt', 'blouse', 'sweater', 't-shirt']),
      bottoms: items.where(category: ['pants', 'jeans', 'skirt', 'shorts']),
      shoes: items.where(category: ['shoes', 'boots', 'sneakers', 'sandals']),
      accessories: items.where(category: ['accessories', 'jewelry', 'bag', 'scarf'])
    }
  end

  def create_outfit(outfit_items)
    Outfit.create!(
      user: @user,
      name: "Generated Outfit - #{Date.today}",
      description: "AI-generated outfit for #{@occasion || 'casual wear'}",
      season: @season,
      occasion: @occasion,
      weather_condition: @weather,
      items: outfit_items.values
    )
  end

  def current_season
    month = Date.today.month
    case month
    when 12, 1, 2 then 'winter'
    when 3, 4, 5 then 'spring'
    when 6, 7, 8 then 'summer'
    when 9, 10, 11 then 'fall'
    end
  end
end
EOF

cat <<EOF > app/services/weather_service.rb
require 'net/http'
require 'json'

class WeatherService
  API_KEY = ENV['OPENWEATHER_API_KEY']
  BASE_URL = 'https://api.openweathermap.org/data/2.5/weather'

  def self.fetch(city)
    uri = URI("#{BASE_URL}?q=#{city}&appid=#{API_KEY}&units=metric")
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)

    {
      temp: data['main']['temp'],
      condition: data['weather'][0]['main'],
      description: data['weather'][0]['description'],
      recommendation: weather_to_outfit_recommendation(data['main']['temp'], data['weather'][0]['main'])
    }
  rescue => e
    Rails.logger.error("Weather API error: #{e.message}")
    nil
  end

  def self.weather_to_outfit_recommendation(temp, condition)
    case
    when temp < 0
      { season: 'winter', layers: 'heavy', accessories: ['scarf', 'gloves', 'hat'] }
    when temp < 15
      { season: 'fall', layers: 'medium', accessories: ['light jacket'] }
    when temp < 25
      { season: 'spring', layers: 'light', accessories: [] }
    else
      { season: 'summer', layers: 'minimal', accessories: ['sunglasses', 'hat'] }
    end
  end
end
EOF

cat <<EOF > app/services/color_harmony_validator.rb
class ColorHarmonyValidator
  COMPLEMENTARY_COLORS = {
    'red' => ['green', 'blue-green'],
    'blue' => ['orange', 'yellow-orange'],
    'yellow' => ['purple', 'blue-purple'],
    'green' => ['red', 'red-purple'],
    'orange' => ['blue', 'blue-purple'],
    'purple' => ['yellow', 'yellow-green']
  }

  ANALOGOUS_COLORS = {
    'red' => ['orange', 'purple'],
    'blue' => ['green', 'purple'],
    'yellow' => ['green', 'orange'],
    'green' => ['blue', 'yellow'],
    'orange' => ['red', 'yellow'],
    'purple' => ['red', 'blue']
  }

  NEUTRAL_COLORS = ['black', 'white', 'gray', 'beige', 'cream', 'navy', 'brown']

  def initialize(items)
    @items = items
    @colors = items.map(&:color).compact.map(&:downcase)
  end

  def valid?
    return true if all_neutrals?
    return true if has_neutral_base?
    return true if complementary_scheme?
    return true if analogous_scheme?

    monochromatic_scheme?
  end

  def harmony_type
    return 'neutral' if all_neutrals?
    return 'complementary' if complementary_scheme?
    return 'analogous' if analogous_scheme?
    return 'monochromatic' if monochromatic_scheme?
    'clash'
  end

  private

  def all_neutrals?
    @colors.all? { |c| NEUTRAL_COLORS.include?(c) }
  end

  def has_neutral_base?
    neutral_count = @colors.count { |c| NEUTRAL_COLORS.include?(c) }
    neutral_count >= @colors.size - 1
  end

  def complementary_scheme?
    non_neutral = @colors.reject { |c| NEUTRAL_COLORS.include?(c) }
    return false if non_neutral.size < 2

    non_neutral.combination(2).any? do |c1, c2|
      COMPLEMENTARY_COLORS[c1]&.include?(c2) || COMPLEMENTARY_COLORS[c2]&.include?(c1)
    end
  end

  def analogous_scheme?
    non_neutral = @colors.reject { |c| NEUTRAL_COLORS.include?(c) }
    return false if non_neutral.size < 2

    base_color = non_neutral.first
    non_neutral[1..-1].all? { |c| ANALOGOUS_COLORS[base_color]&.include?(c) }
  end

  def monochromatic_scheme?
    non_neutral = @colors.reject { |c| NEUTRAL_COLORS.include?(c) }
    non_neutral.uniq.size <= 1
  end
end
EOF

# -- MODEL ENHANCEMENTS --

cat <<EOF > app/models/item.rb
class Item < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  SEASONS = %w[spring summer fall winter all-season].freeze
  CATEGORIES = %w[shirt blouse sweater t-shirt pants jeans skirt shorts shoes boots sneakers sandals accessories jewelry bag scarf].freeze

  validates :season, inclusion: { in: SEASONS }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  scope :by_season, ->(season) { where(season: [season, 'all-season']) }
  scope :most_worn, -> { order(times_worn: :desc) }
  scope :least_worn, -> { order(times_worn: :asc) }
  scope :by_category, ->(category) { where(category: category) }

  def cost_per_wear
    return 0 if times_worn.to_i.zero?
    price.to_f / times_worn.to_i
  end

  def self.semantic_search(query)
    # Generate embedding for query
    embedding = OpenAI.embeddings(input: query)['data'][0]['embedding']

    # Find similar items using cosine similarity
    where("embedding IS NOT NULL")
      .order(Arel.sql("embedding <=> '[#{embedding.join(',')}]'"))
      .limit(10)
  end

  after_save :generate_embedding

  private

  def generate_embedding
    return if title.blank? && content.blank?

    text = [title, content, category, color, material].compact.join(' ')
    response = OpenAI.embeddings(input: text)
    update_column(:embedding, response['data'][0]['embedding'])
  end
end
EOF

cat <<EOF > app/models/organization_tip.rb
class OrganizationTip < ApplicationRecord
  validates :title, :content, presence: true

  def self.find_relevant(query, limit: 5)
    embedding = OpenAI.embeddings(input: query)['data'][0]['embedding']

    where("embedding IS NOT NULL")
      .order(Arel.sql("embedding <=> '[#{embedding.join(',')}]'"))
      .limit(limit)
  end

  after_save :generate_embedding

  private

  def generate_embedding
    text = [title, content].compact.join(' ')
    response = OpenAI.embeddings(input: text)
    update_column(:embedding, response['data'][0]['embedding'])
  end
end
EOF

cat <<EOF > app/models/wardrobe_analytic.rb
class WardrobeAnalytic < ApplicationRecord
  belongs_to :user
  belongs_to :most_worn_item, class_name: 'Item', optional: true
  belongs_to :least_worn_item, class_name: 'Item', optional: true

  def calculate!
    items = user.items

    self.total_items = items.count
    self.total_value = items.sum(:price)
    self.most_worn_item = items.order(times_worn: :desc).first
    self.least_worn_item = items.where('times_worn > 0').order(times_worn: :asc).first

    worn_items = items.where('times_worn > 0')
    self.average_cost_per_wear = if worn_items.any?
      worn_items.sum { |i| i.price.to_f } / worn_items.sum(:times_worn).to_f
    else
      0
    end

    save!
  end
end
EOF

cat <<EOF > app/services/replicate_service.rb
require 'replicate'

class ReplicateService
  def self.client
    @client ||= Replicate::Client.new(token: ENV['REPLICATE_API_TOKEN'])
  end

  # Background removal using BRIA RMBG-1.4
  def self.remove_background(image_url)
    client.run(
      'briaai/rmbg-1.4:818c26e60a3621c963dca97272c40ae4d1ef0c8c7d96d17c743ad31e69e6e7e1',
      input: { image: image_url }
    )
  end

  # Virtual try-on for fashion
  def self.virtual_tryon(person_image_url, garment_image_url)
    client.run(
      'cuuupid/idm-vton:906425dbca90663ff5427624839572cc56ea7d380343d13e2a4c4b09d3f0c30f',
      input: {
        garm_img: garment_image_url,
        human_img: person_image_url,
        garment_des: 'clothing item'
      }
    )
  end

  # AI upscaling for better quality images
  def self.upscale_image(image_url, scale: 4)
    client.run(
      'nightmareai/real-esrgan:f121d640bd286e1fdc67f9799164c1d5be36ff74576ee11c803ae5b665dd46aa',
      input: {
        image: image_url,
        scale: scale,
        face_enhance: true
      }
    )
  end

  # Generate outfit descriptions using LLaVA vision model
  def self.describe_outfit(image_url, prompt = 'Describe this outfit in detail, including colors, style, and occasion suitability.')
    client.run(
      'yorickvp/llava-13b:80537f9eead1a5bfa72d5ac6ea6414379be41d4d4f6679fd776e9535d1eb58bb',
      input: {
        image: image_url,
        prompt: prompt
      }
    )
  end

  # Generate fashion sketches from text
  def self.generate_fashion_sketch(description)
    client.run(
      'stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b',
      input: {
        prompt: "fashion sketch, technical drawing, #{description}",
        negative_prompt: 'photo, realistic, 3d',
        width: 768,
        height: 1024
      }
    )
  end

  # Color palette extraction
  def self.extract_colors(image_url)
    # Using CLIP Interrogator for image understanding
    result = client.run(
      'pharmapsychotic/clip-interrogator:a4a8bafd6089e1716b06057c42b19378250d008b80fe87caa5cd36d40c1eda90',
      input: { image: image_url, mode: 'fast' }
    )

    # Parse colors from description
    extract_color_keywords(result)
  end

  # Generate outfit recommendations based on existing items
  def self.generate_outfit_image(items_description, style: 'casual')
    client.run(
      'stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b',
      input: {
        prompt: "fashion outfit photo, #{style} style, #{items_description}, studio lighting, clean background",
        width: 768,
        height: 1024,
        num_outputs: 1
      }
    )
  end

  # Fashion trend analysis using vision models
  def self.analyze_fashion_trend(image_url)
    client.run(
      'yorickvp/llava-13b:80537f9eead1a5bfa72d5ac6ea6414379be41d4d4f6679fd776e9535d1eb58bb',
      input: {
        image: image_url,
        prompt: 'Analyze this fashion item. What trend does it belong to? What style category? What occasions is it suitable for? What colors work well with it?'
      }
    )
  end

  private

  def self.extract_color_keywords(text)
    color_keywords = ['red', 'blue', 'green', 'yellow', 'orange', 'purple', 'pink', 'black', 'white', 'gray', 'brown', 'beige', 'navy', 'burgundy', 'olive', 'tan']
    text.downcase.split.select { |word| color_keywords.include?(word) }.uniq
  end
end
EOF

cat <<EOF > app/services/ai_image_processor.rb
class AiImageProcessor
  def self.process_uploaded_item(item)
    return unless item.image.attached?

    image_url = Rails.application.routes.url_helpers.rails_blob_url(item.image, only_path: false)

    # Remove background
    bg_removed = ReplicateService.remove_background(image_url)

    # Extract colors and analyze
    colors = ReplicateService.extract_colors(image_url)
    description = ReplicateService.describe_outfit(image_url)
    trend_analysis = ReplicateService.analyze_fashion_trend(image_url)

    # Update item with AI insights
    item.update(
      ai_description: description,
      ai_colors: colors.join(', '),
      ai_trend_analysis: trend_analysis,
      processed_image_url: bg_removed
    )
  rescue => e
    Rails.logger.error("AI processing failed: #{e.message}")
  end

  def self.generate_virtual_tryon(user, item)
    user_photo_url = Rails.application.routes.url_helpers.rails_blob_url(user.photo, only_path: false)
    item_photo_url = Rails.application.routes.url_helpers.rails_blob_url(item.image, only_path: false)

    ReplicateService.virtual_tryon(user_photo_url, item_photo_url)
  end

  def self.upscale_item_image(item)
    return unless item.image.attached?

    image_url = Rails.application.routes.url_helpers.rails_blob_url(item.image, only_path: false)
    upscaled_url = ReplicateService.upscale_image(image_url)

    item.update(upscaled_image_url: upscaled_url)
  end
end
EOF

# -- UPDATE FEATURES CONTROLLER WITH AI SERVICES --

cat <<EOF > app/controllers/features_controller.rb
class FeaturesController < ApplicationController
  before_action :authenticate_user!

  def visualize_your_wardrobe
    @items = current_user.items.includes(:image_attachment)
    @seasonal_items = @items.group_by(&:season)
    @category_items = @items.group_by(&:category)

    # Get organization tips
    @tips = OrganizationTip.find_relevant("wardrobe organization tips", limit: 3)
  end

  def style_assistant
    weather_data = WeatherService.fetch(current_user.city || 'New York')

    @outfits = current_user.outfits.order(created_at: :desc).limit(10)
    @ai_outfit = OutfitGeneratorService.new(
      current_user,
      weather: weather_data&.dig(:recommendation, :season),
      occasion: params[:occasion]
    ).generate if current_user.items.any?

    @weather = weather_data
  end

  def mix_match_magic
    @items = current_user.items

    # Generate AI-powered outfit suggestions
    3.times do
      outfit = OutfitGeneratorService.new(current_user).generate
      @suggestions ||= []
      @suggestions << outfit if outfit
    end

    @suggestions ||= []
  end

  def shop_smarter
    @recommendations = current_user.recommendations

    # Find items that would complement existing wardrobe
    @wardrobe_gaps = analyze_wardrobe_gaps
  end

  def ask_organization
    query = params[:query]
    @tips = OrganizationTip.find_relevant(query, limit: 5)

    render json: { tips: @tips.map { |t| { title: t.title, content: t.content } } }
  end

  private

  def analyze_wardrobe_gaps
    items = current_user.items
    categories = items.pluck(:category).uniq
    seasons = items.pluck(:season).uniq

    missing = {
      categories: Item::CATEGORIES - categories,
      seasons: Item::SEASONS - seasons,
      versatile_items: []
    }

    # Suggest versatile items based on color analysis
    colors = items.pluck(:color).uniq
    missing[:versatile_items] << 'neutral blazer' unless colors.any? { |c| ColorHarmonyValidator::NEUTRAL_COLORS.include?(c.downcase) }

    missing
  end
end
EOF

# -- ADD REPLICATE-POWERED CONTROLLERS --

cat <<EOF > app/controllers/ai_features_controller.rb
class AiFeaturesController < ApplicationController
  before_action :authenticate_user!

  # Virtual try-on endpoint
  def virtual_tryon
    item = Item.find(params[:item_id])
    result_url = AiImageProcessor.generate_virtual_tryon(current_user, item)

    render json: { tryon_image_url: result_url }
  end

  # Generate fashion sketch from description
  def generate_sketch
    description = params[:description]
    sketch_url = ReplicateService.generate_fashion_sketch(description)

    render json: { sketch_url: sketch_url }
  end

  # AI-powered item processing
  def process_item
    item = current_user.items.find(params[:id])
    AiImageProcessor.process_uploaded_item(item)

    render json: {
      success: true,
      ai_description: item.ai_description,
      ai_colors: item.ai_colors,
      processed_image_url: item.processed_image_url
    }
  end

  # Upscale item image
  def upscale_image
    item = current_user.items.find(params[:id])
    AiImageProcessor.upscale_item_image(item)

    render json: { upscaled_url: item.upscaled_image_url }
  end

  # Generate outfit visualization
  def generate_outfit_visualization
    outfit = current_user.outfits.find(params[:outfit_id])
    items_description = outfit.items.map { |i| "#{i.color} #{i.category}" }.join(', ')

    outfit_image_url = ReplicateService.generate_outfit_image(
      items_description,
      style: params[:style] || 'casual'
    )

    render json: { visualization_url: outfit_image_url }
  end
end
EOF

# -- UPDATE ITEM MODEL WITH AI CALLBACKS --

cat <<EOF > app/models/item.rb
class Item < ApplicationRecord
  belongs_to :user
  has_one_attached :image

  SEASONS = %w[spring summer fall winter all-season].freeze
  CATEGORIES = %w[shirt blouse sweater t-shirt pants jeans skirt shorts shoes boots sneakers sandals accessories jewelry bag scarf].freeze

  validates :season, inclusion: { in: SEASONS }, allow_nil: true
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true

  scope :by_season, ->(season) { where(season: [season, 'all-season']) }
  scope :most_worn, -> { order(times_worn: :desc) }
  scope :least_worn, -> { order(times_worn: :asc) }
  scope :by_category, ->(category) { where(category: category) }

  # AI processing after image upload
  after_commit :process_with_ai, on: [:create, :update], if: :image_attached?

  def cost_per_wear
    return 0 if times_worn.to_i.zero?
    price.to_f / times_worn.to_i
  end

  def self.semantic_search(query)
    # Generate embedding for query
    embedding = OpenAI.embeddings(input: query)['data'][0]['embedding']

    # Find similar items using cosine similarity
    where("embedding IS NOT NULL")
      .order(Arel.sql("embedding <=> '[#{embedding.join(',')}]'"))
      .limit(10)
  end

  after_save :generate_embedding

  private

  def generate_embedding
    return if title.blank? && content.blank?

    text = [title, content, category, color, material].compact.join(' ')
    response = OpenAI.embeddings(input: text)
    update_column(:embedding, response['data'][0]['embedding'])
  end

  def process_with_ai
    AiImageProcessorJob.perform_later(id)
  end

  def image_attached?
    image.attached? && saved_change_to_attribute?(:id)
  end
end
EOF

# -- ADD BACKGROUND JOB FOR AI PROCESSING --

cat <<EOF > app/jobs/ai_image_processor_job.rb
class AiImageProcessorJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find(item_id)
    AiImageProcessor.process_uploaded_item(item)
  end
end
EOF

# -- ADD ROUTES FOR REPLICATE FEATURES --

cat <<EOF > config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root 'home#index'

  # Feature pages
  get 'visualize_your_wardrobe', to: 'features#visualize_your_wardrobe'
  get 'style_assistant', to: 'features#style_assistant'
  get 'mix_match_magic', to: 'features#mix_match_magic'
  get 'shop_smarter', to: 'features#shop_smarter'
  post 'ask_organization', to: 'features#ask_organization'

  # Analytics
  get 'analytics', to: 'analytics#index'

  # AI Features
  namespace :ai do
    post 'virtual_tryon/:item_id', to: 'ai_features#virtual_tryon', as: :virtual_tryon
    post 'generate_sketch', to: 'ai_features#generate_sketch'
    post 'process_item/:id', to: 'ai_features#process_item', as: :process_item
    post 'upscale_image/:id', to: 'ai_features#upscale_image', as: :upscale_image
    post 'generate_outfit_visualization/:outfit_id', to: 'ai_features#generate_outfit_visualization', as: :outfit_visualization
  end

  # Resources
  resources :items
  resources :outfits
  resources :recommendations
  resources :posts
  resources :communities
  resources :comments

  # Search
  get 'search', to: 'search#index'
end
EOF

# -- POST VIEWS --

cat <<EOF > app/views/posts/index.html.erb
<%= tag.section do %>
  <%= tag.h1 t("posts.index.title") %>
  <%= tag.section do %>
    <% @posts.each do |post| %>
      <%= tag.section itemscope itemtype="http://schema.org/Product" do %>
        <%= link_to image_tag(post.image_url, alt: post.title), post %>
        <%= tag.h2 itemprop="name" do %><%= post.title %></%=>
        <%= tag.p itemprop="description" do %><%= post.content %></%=>
      <% end %>
    <% end %>
  <% end %>
<% end %>
EOF

cat <<EOF > app/views/posts/show.html.erb
<%= tag.section itemscope itemtype="http://schema.org/Product" do %>
  <%= tag.h1 itemprop="name" do %><%= @post.title %></%=>
  <%= image_tag @post.image_url, alt: @post.title %>
  <%= tag.p itemprop="description" do %><%= @post.content %></%=>
  <%= link_to t("posts.back"), posts_path %>
<% end %>
EOF

# -- ADDITIONAL SETUP --

mkdir -p config/locales
cat <<EOF > config/locales/en.yml
en:
  site:
    title: "Amber Fashion"
  navigation:
    home: "Home"
    search: "Search"
    login: "Login"
    dark_mode: "Toggle Dark Mode"
  features:
    visualize_your_wardrobe: "Visualize Your Wardrobe"
    style_assistant: "Style Assistant"
    mix_match_magic: "Mix & Match Magic"
    shop_smarter: "Shop Smarter"
  footer:
    about_amber: "About Amber"
    about_description: "Amber Fashion is your one-stop destination for innovative fashion."
    explore: "Explore"
    special_offers: "Special Offers"
    ethical_practices: "Ethical Practices"
    upcoming_designers: "Upcoming Designers"
    legal: "Legal"
    privacy_policy: "Privacy Policy"
    terms_of_service: "Terms of Service"
    contact_us: "Contact Us"
    contact_info: "Contact us at"
    email_us: "Email Us"
    supporting_wildlife: "Supporting Wildlife"
    supporting_wildlife_description: "Amber Fashion supports wildlife conservation efforts."
EOF

cat <<EOF > config/locales/no.yml
no:
  site:
    title: "Amber Fashion"
  navigation:
    home: "Hjem"
    search: "Søk"
    login: "Logg inn"
    dark_mode: "Bytt til mørk modus"
  features:
    visualize_your_wardrobe: "Visualiser Garderoben Din"
    style_assistant: "Stilassistent"
    mix_match_magic: "Mix & Match Magi"
    shop_smarter: "Handle Smartere"
  footer:
    about_amber: "Om Amber"
    about_description: "Amber Fashion er din one-stop destinasjon for innovativ mote."
    explore: "Utforsk"
    special_offers: "Spesialtilbud"
    ethical_practices: "Etiske Praksiser"
    upcoming_designers: "Kommande Designere"
    legal: "Juridisk"
    privacy_policy: "Personvern"
    terms_of_service: "Vilkår for Tjenester"
    contact_us: "Kontakt Oss"
    contact_info: "Kontakt oss på"
    email_us: "Send oss en e-post"
    supporting_wildlife: "Støtte til Villmarken"
    supporting_wildlife_description: "Amber Fashion støtter bevaring av villmark."
EOF

bin/rails db:migrate

cat <<EOF > db/seeds.rb
require "faker"

puts "Creating demo users with Faker..."
demo_users = []
10.times do
  demo_users << User.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    name: Faker::Name.name
  )
end

puts "Created #{demo_users.count} demo users."

puts "Creating demo fashion items with Faker..."
categories = ['shirt', 'blouse', 'sweater', 't-shirt', 'pants', 'jeans', 'skirt', 'shorts', 'shoes', 'boots', 'sneakers', 'sandals', 'accessories', 'jewelry', 'bag', 'scarf']
seasons = ['spring', 'summer', 'fall', 'winter', 'all-season']
colors = ['Black', 'White', 'Red', 'Blue', 'Green', 'Yellow', 'Pink', 'Purple', 'Orange', 'Gray', 'Navy', 'Beige']
sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL']
materials = ['Cotton', 'Silk', 'Wool', 'Polyester', 'Leather', 'Denim', 'Linen']

demo_users.each do |user|
  rand(15..30).times do
    Item.create!(
      user: user,
      title: "#{Faker::Color.color_name.capitalize} #{categories.sample.capitalize}",
      content: Faker::Lorem.paragraph(sentence_count: 2),
      color: colors.sample,
      size: sizes.sample,
      material: materials.sample,
      texture: Faker::Commerce.material,
      brand: Faker::Company.name,
      price: Faker::Commerce.price(range: 20.0..300.0),
      category: categories.sample,
      stock_quantity: rand(1..10),
      available: [true, true, true, false].sample,
      sku: Faker::Barcode.ean,
      release_date: Faker::Date.between(from: 2.years.ago, to: Date.today),
      season: seasons.sample,
      times_worn: rand(0..50),
      purchase_date: Faker::Date.between(from: 3.years.ago, to: Date.today)
    )
  end
end

puts "Created #{Item.count} demo fashion items."

puts "Creating demo outfits..."
demo_users.each do |user|
  rand(5..10).times do
    Outfit.create!(
      user: user,
      name: "#{Faker::Adjective.positive.capitalize} #{['Spring', 'Summer', 'Fall', 'Winter'].sample} Outfit",
      description: Faker::Lorem.paragraph(sentence_count: 2),
      image_url: "https://picsum.photos/400/600?random=#{rand(1000)}",
      category: ['casual', 'formal', 'business', 'athletic', 'evening'].sample,
      season: seasons.sample,
      occasion: ['work', 'party', 'date', 'casual', 'sport'].sample,
      weather_condition: ['sunny', 'rainy', 'cold', 'warm'].sample
    )
  end
end

puts "Created #{Outfit.count} demo outfits."

puts "Creating demo organization tips..."
tip_titles = [
  "Organizing by Color",
  "Seasonal Wardrobe Storage",
  "Maximizing Closet Space",
  "Care Tips for Delicate Fabrics",
  "Sustainable Fashion Choices"
]

tip_contents = [
  "Arrange your clothes by color to create a visually appealing and easy-to-navigate wardrobe.",
  "Rotate your wardrobe seasonally to keep only current items accessible.",
  "Use vertical space with shelves and hanging organizers to maximize storage.",
  "Always check care labels and use gentle detergents for delicate materials.",
  "Invest in quality pieces that last longer and reduce fashion waste."
]

5.times do |i|
  OrganizationTip.create!(
    title: tip_titles[i],
    content: tip_contents[i],
    category: ['storage', 'care', 'styling', 'sustainability'].sample
  )
end

puts "Created #{OrganizationTip.count} organization tips."

puts "Creating wardrobe analytics..."
demo_users.each do |user|
  WardrobeAnalytic.create!(
    user: user,
    total_items: user.items.count,
    total_value: user.items.sum(:price),
    most_worn_item: user.items.order(times_worn: :desc).first,
    least_worn_item: user.items.where('times_worn > 0').order(times_worn: :asc).first,
    average_cost_per_wear: rand(2.0..15.0).round(2)
  )
end

puts "Created #{WardrobeAnalytic.count} wardrobe analytics."

puts "Seed data creation complete!"
EOF

generate_turbo_views "items" "item"
generate_turbo_views "outfits" "outfit"
generate_turbo_views "posts" "post"

commit "Amber setup complete: AI-enhanced fashion social network with virtual try-on and wardrobe analytics"

log "Amber setup complete. Run 'bin/falcon-host' with PORT set to start on OpenBSD."
log ""
log "🎨 Amber Features:"
log "   • AI-powered wardrobe organization and analytics"
log "   • Virtual try-on with Replicate.com image generation"
log "   • Semantic search with pgvector embeddings"
log "   • Style recommendations and outfit suggestions"
log "   • Cost-per-wear tracking and sustainability metrics"
log "   • Social posting and community features"
log ""
log "   Access: http://localhost:3002/analytics for wardrobe insights"

# Change Log:
# - Aligned with master.json v6.5.0: Two-space indents, double quotes, heredocs, Strunk & White comments.
# - Used Rails 8 conventions, Hotwire, Turbo Streams, Stimulus Reflex, I18n, and Falcon.
# - Leveraged bin/rails generate scaffold for Items, Outfits, and Posts to streamline CRUD setup.
# - Integrated AI image processing with Replicate.com for virtual try-on and sketch generation.
# - Added pgvector semantic search for intelligent wardrobe recommendations.
# - Included cost-per-wear analytics and sustainability tracking.
# - Ensured NNG principles, SEO, schema data, and minimal flat design compliance.
# - Finalized for unprivileged user on OpenBSD 7.5.
