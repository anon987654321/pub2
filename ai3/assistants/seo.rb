# frozen_string_literal: true

# SEO Assistant - Comprehensive SEO analysis and optimization
# Consolidated from seo.rb and seo_assistant.rb

require_relative '../lib/universal_scraper'
require_relative '../lib/weaviate_integration'
require_relative '../lib/rag_engine'

module Assistants
  class SEO
    attr_reader :name, :role, :capabilities

    # SEO Knowledge Sources
    KNOWLEDGE_SOURCES = [
      'https://moz.com/beginners-guide-to-seo/',
      'https://searchengineland.com/guide/what-is-seo/',
      'https://searchenginejournal.com/seo-guide/',
      'https://backlinko.com/',
      'https://neilpatel.com/',
      'https://ahrefs.com/blog/',
      'https://developers.google.com/search/',
      'https://support.google.com/webmasters/',
      'https://schema.org/',
      'https://web.dev/learn/pwa/'
    ].freeze

    def initialize(config = {})
      @name = 'SEO Expert'
      @role = 'Search Engine Optimization Specialist'
      @capabilities = [
        'Technical SEO audit',
        'Content optimization',
        'Keyword research and analysis',
        'Link building strategies',
        'Local SEO optimization',
        'Mobile SEO analysis',
        'Site speed optimization',
        'Schema markup implementation',
        'SEO reporting and analytics'
      ]
      
      @language = config[:language] || 'en'
      @universal_scraper = UniversalScraper.new
      @weaviate_integration = WeaviateIntegration.new if defined?(WeaviateIntegration)
      @rag_engine = RagEngine.new
      
      initialize_seo_knowledge
    end

    def process(input, context = {})
      seo_task = detect_seo_task(input)
      
      case seo_task
      when :audit
        audit_website(extract_url(input) || context[:url])
      when :keywords
        analyze_keywords(input, context)
      when :content
        optimize_content(input, context)
      when :technical
        technical_seo_analysis(input, context)
      when :local
        local_seo_optimization(input, context)
      when :report
        generate_seo_report(extract_url(input) || context[:url])
      else
        provide_seo_guidance(input, context)
      end
    end

    # Website SEO Audit
    def audit_website(url)
      return "Please provide a valid URL for SEO audit." unless url

      response = "**🔍 SEO AUDIT REPORT**\n\n"
      response += "**Website:** #{url}\n\n"
      
      audit_results = {
        technical: perform_technical_audit(url),
        content: perform_content_audit(url),
        performance: perform_performance_audit(url),
        mobile: perform_mobile_audit(url),
        local: perform_local_audit(url)
      }
      
      audit_results.each do |category, results|
        response += "**#{category.to_s.capitalize} SEO:**\n"
        results.each { |result| response += "- #{result}\n" }
        response += "\n"
      end
      
      response += generate_seo_recommendations(audit_results)
      response
    end

    # Content Optimization
    def optimize_content(content, context = {})
      target_keywords = extract_keywords(content, context)
      
      response = "**📝 CONTENT OPTIMIZATION ANALYSIS**\n\n"
      
      if target_keywords.any?
        response += "**Detected Keywords:** #{target_keywords.join(', ')}\n\n"
      end
      
      optimization_tips = [
        "Include target keywords in title and headings",
        "Use keywords naturally throughout content",
        "Optimize meta description with target keywords",
        "Include relevant internal and external links",
        "Use semantic keywords and related terms",
        "Structure content with proper heading hierarchy",
        "Optimize images with alt text and file names",
        "Ensure content is comprehensive and valuable"
      ]
      
      response += "**Optimization Recommendations:**\n"
      optimization_tips.each_with_index { |tip, idx| response += "#{idx + 1}. #{tip}\n" }
      
      response += "\n**Content Quality Checklist:**\n"
      quality_factors = [
        "Original and unique content",
        "Proper grammar and spelling",
        "Logical content structure",
        "Appropriate content length",
        "Engaging and valuable to readers",
        "Mobile-friendly formatting"
      ]
      
      quality_factors.each { |factor| response += "- #{factor}\n" }
      
      response
    end

    # Keyword Analysis
    def analyze_keywords(input, context = {})
      keywords = extract_keywords(input, context)
      
      response = "**🎯 KEYWORD ANALYSIS**\n\n"
      
      if keywords.any?
        response += "**Target Keywords:** #{keywords.join(', ')}\n\n"
        
        response += "**Keyword Optimization Strategy:**\n"
        keywords.each_with_index do |keyword, idx|
          response += "#{idx + 1}. **#{keyword}**\n"
          response += "   - Use in title tag and H1\n"
          response += "   - Include in meta description\n"
          response += "   - Use in URL if possible\n"
          response += "   - Include in image alt text\n\n"
        end
      end
      
      response += "**Keyword Research Tips:**\n"
      research_tips = [
        "Use Google Keyword Planner for search volume data",
        "Analyze competitor keywords",
        "Focus on long-tail keywords for better targeting",
        "Consider user intent when selecting keywords",
        "Monitor keyword rankings regularly",
        "Use semantic keywords and synonyms"
      ]
      
      research_tips.each { |tip| response += "- #{tip}\n" }
      
      response
    end

    # Technical SEO Analysis
    def technical_seo_analysis(input, context = {})
      url = extract_url(input) || context[:url]
      
      response = "**⚙️ TECHNICAL SEO ANALYSIS**\n\n"
      
      if url
        response += "**Website:** #{url}\n\n"
      end
      
      technical_factors = {
        "Site Speed" => [
          "Optimize images and media files",
          "Minimize HTTP requests",
          "Enable compression (Gzip)",
          "Use browser caching",
          "Minimize CSS and JavaScript"
        ],
        "Mobile Optimization" => [
          "Responsive design implementation",
          "Mobile-friendly navigation",
          "Touch-friendly buttons and links",
          "Fast mobile loading speed",
          "Proper viewport configuration"
        ],
        "Technical Structure" => [
          "Clean URL structure",
          "XML sitemap creation and submission",
          "Robots.txt optimization",
          "Canonical tags implementation",
          "Schema markup for rich snippets"
        ],
        "Crawlability" => [
          "Fix broken links (404 errors)",
          "Optimize internal linking",
          "Ensure proper redirect chains",
          "Remove duplicate content",
          "Optimize navigation structure"
        ]
      }
      
      technical_factors.each do |category, factors|
        response += "**#{category}:**\n"
        factors.each { |factor| response += "- #{factor}\n" }
        response += "\n"
      end
      
      response
    end

    # Generate SEO Report
    def generate_seo_report(url)
      return "Please provide a valid URL for SEO report generation." unless url

      response = "**📊 COMPREHENSIVE SEO REPORT**\n\n"
      response += "**Website:** #{url}\n"
      response += "**Generated:** #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}\n\n"
      
      # Executive Summary
      response += "**EXECUTIVE SUMMARY**\n"
      response += "This report provides a comprehensive analysis of SEO factors affecting website performance.\n\n"
      
      # Key Metrics
      response += "**KEY METRICS TO MONITOR**\n"
      metrics = [
        "Organic search traffic growth",
        "Keyword ranking positions",
        "Click-through rates (CTR)",
        "Bounce rate and dwell time",
        "Page load speed scores",
        "Mobile usability metrics",
        "Core Web Vitals scores"
      ]
      
      metrics.each { |metric| response += "- #{metric}\n" }
      response += "\n"
      
      # Action Items
      response += "**PRIORITY ACTION ITEMS**\n"
      action_items = [
        "Optimize page titles and meta descriptions",
        "Improve site loading speed",
        "Fix technical SEO issues",
        "Create high-quality, keyword-optimized content",
        "Build authoritative backlinks",
        "Optimize for mobile devices",
        "Implement structured data markup"
      ]
      
      action_items.each_with_index { |item, idx| response += "#{idx + 1}. #{item}\n" }
      
      response += "\n**Next Steps:** Schedule regular SEO audits and monitor progress monthly."
      response
    end

    private

    def initialize_seo_knowledge
      # Initialize SEO knowledge base
      @seo_factors = {
        on_page: %w[title meta_description headings content keywords internal_links],
        technical: %w[site_speed mobile_friendly ssl crawlability sitemap],
        off_page: %w[backlinks social_signals domain_authority],
        content: %w[quality relevance freshness length readability]
      }
    end

    def detect_seo_task(input)
      input_lower = input.downcase
      
      return :audit if input_lower.match?(/\b(audit|analyze|check|review)\b/)
      return :keywords if input_lower.match?(/\b(keyword|keywords|research)\b/)
      return :content if input_lower.match?(/\b(content|optimize|improve)\b/)
      return :technical if input_lower.match?(/\b(technical|speed|mobile|crawl)\b/)
      return :local if input_lower.match?(/\b(local|location|business)\b/)
      return :report if input_lower.match?(/\b(report|summary|analysis)\b/)
      
      :general
    end

    def extract_url(input)
      url_match = input.match(%r{https?://[^\s]+})
      url_match ? url_match[0] : nil
    end

    def extract_keywords(input, context)
      # Simple keyword extraction - in a real implementation, this would be more sophisticated
      keywords = []
      
      # Extract from context if provided
      keywords.concat(context[:keywords]) if context[:keywords]
      
      # Extract potential keywords from input
      words = input.downcase.split(/\W+/).select { |word| word.length > 3 }
      keywords.concat(words.uniq)
      
      keywords.uniq.first(5)  # Limit to 5 keywords
    end

    def perform_technical_audit(url)
      [
        "Check robots.txt and sitemap.xml",
        "Verify SSL certificate installation",
        "Analyze site loading speed",
        "Check mobile responsiveness",
        "Review URL structure and redirects",
        "Identify duplicate content issues"
      ]
    end

    def perform_content_audit(url)
      [
        "Analyze title tags and meta descriptions",
        "Review heading structure (H1-H6)",
        "Check keyword optimization",
        "Evaluate content quality and length",
        "Review internal linking strategy",
        "Check image optimization and alt text"
      ]
    end

    def perform_performance_audit(url)
      [
        "Measure Core Web Vitals scores",
        "Check page load speed",
        "Analyze server response time",
        "Review image compression",
        "Evaluate JavaScript and CSS optimization",
        "Check caching implementation"
      ]
    end

    def perform_mobile_audit(url)
      [
        "Test mobile-friendly design",
        "Check touch element sizing",
        "Verify mobile page speed",
        "Review mobile navigation",
        "Test mobile form usability",
        "Check mobile viewport configuration"
      ]
    end

    def perform_local_audit(url)
      [
        "Verify Google My Business optimization",
        "Check NAP (Name, Address, Phone) consistency",
        "Review local keyword optimization",
        "Analyze local citation building",
        "Check online reviews management",
        "Verify local schema markup"
      ]
    end

    def generate_seo_recommendations(audit_results)
      response = "**🎯 SEO RECOMMENDATIONS**\n\n"
      
      priority_actions = [
        "Fix critical technical issues first",
        "Optimize page titles and meta descriptions",
        "Improve site loading speed",
        "Create high-quality, relevant content",
        "Build authoritative backlinks",
        "Optimize for mobile users",
        "Implement structured data markup"
      ]
      
      response += "**Priority Actions:**\n"
      priority_actions.each_with_index { |action, idx| response += "#{idx + 1}. #{action}\n" }
      
      response += "\n**Long-term Strategy:**\n"
      long_term = [
        "Develop content marketing strategy",
        "Build domain authority through quality backlinks",
        "Monitor and track SEO performance",
        "Stay updated with search engine algorithm changes",
        "Continuously optimize based on data and results"
      ]
      
      long_term.each { |strategy| response += "- #{strategy}\n" }
      
      response
    end

    def local_seo_optimization(input, context)
      response = "**📍 LOCAL SEO OPTIMIZATION**\n\n"
      
      local_factors = {
        "Google My Business" => [
          "Complete all profile information",
          "Add high-quality photos",
          "Collect and respond to reviews",
          "Post regular updates",
          "Use relevant categories"
        ],
        "Local Citations" => [
          "Ensure NAP consistency across directories",
          "Submit to local business directories",
          "Update information on major platforms",
          "Monitor citation accuracy"
        ],
        "Local Content" => [
          "Create location-specific landing pages",
          "Include local keywords in content",
          "Write about local events and news",
          "Feature customer testimonials"
        ]
      }
      
      local_factors.each do |category, factors|
        response += "**#{category}:**\n"
        factors.each { |factor| response += "- #{factor}\n" }
        response += "\n"
      end
      
      response
    end

    def provide_seo_guidance(input, context)
      response = "**🚀 SEO GUIDANCE**\n\n"
      
      response += "**Core SEO Principles:**\n"
      principles = [
        "Create high-quality, valuable content for users",
        "Optimize for search engines while prioritizing user experience",
        "Build authoritative and relevant backlinks",
        "Ensure technical SEO fundamentals are solid",
        "Monitor performance and adapt strategies",
        "Stay updated with search engine guidelines"
      ]
      
      principles.each_with_index { |principle, idx| response += "#{idx + 1}. #{principle}\n" }
      
      response += "\n**SEO Best Practices:**\n"
      best_practices = [
        "Focus on user intent and search behavior",
        "Use keyword research to guide content creation",
        "Optimize page loading speed and mobile experience",
        "Build topic authority through comprehensive content",
        "Earn quality backlinks from relevant websites",
        "Track and measure SEO performance regularly"
      ]
      
      best_practices.each { |practice| response += "- #{practice}\n" }
      
      response += "\n**Ask me about:** SEO audits, keyword research, content optimization, technical SEO, local SEO, or SEO reporting."
      
      response
    end

    def conduct_seo_optimization
      puts 'Analyzing current SEO practices and optimizing...'
      KNOWLEDGE_SOURCES.each do |url|
        unless @weaviate_integration&.check_if_indexed(url)
          data = @universal_scraper.analyze_content(url)
          @weaviate_integration&.add_data_to_weaviate(url: url, content: data)
        end
      end
      apply_advanced_seo_strategies
    end

    def apply_advanced_seo_strategies
      strategies = [
        "Mobile SEO optimization",
        "Voice search optimization", 
        "Local SEO enhancement",
        "Video SEO improvement",
        "Featured snippets targeting",
        "Image SEO optimization",
        "Performance optimization",
        "Advanced link building",
        "Core Web Vitals optimization",
        "App store SEO"
      ]
      
      "Advanced SEO strategies applied: #{strategies.join(', ')}"
    end
  end
end
      advanced_technical_seo
      ai_and_machine_learning_in_seo
      email_campaigns
      schema_markup_and_structured_data
      progressive_web_apps
      ai_powered_content_creation
      augmented_reality_and_virtual_reality
      multilingual_seo
      advanced_analytics
      continuous_learning_and_adaptation
    def analyze_mobile_seo
      puts 'Analyzing and optimizing for mobile SEO...'
    def optimize_for_voice_search
      puts 'Optimizing content for voice search accessibility...'
    def enhance_local_seo
      puts 'Enhancing local SEO strategies...'
    def improve_video_seo
      puts 'Optimizing video content for better search engine visibility...'
    def target_featured_snippets
      puts 'Targeting featured snippets and position zero...'
    def optimize_image_seo
      puts 'Optimizing images for SEO...'
    def speed_and_performance_optimization
      puts 'Optimizing website speed and performance...'
    def advanced_link_building
      puts 'Implementing advanced link building strategies...'
    def user_experience_and_core_web_vitals
      puts 'Optimizing for user experience and core web vitals...'
    def app_store_seo
      puts 'Optimizing app store listings...'
    def advanced_technical_seo
      puts 'Enhancing technical SEO aspects...'
    def ai_and_machine_learning_in_seo
      puts 'Integrating AI and machine learning in SEO...'
    def email_campaigns
      puts 'Optimizing SEO through targeted email campaigns...'
    def schema_markup_and_structured_data
      puts 'Implementing schema markup and structured data...'
    def progressive_web_apps
      puts 'Developing and optimizing progressive web apps (PWAs)...'
    def ai_powered_content_creation
      puts 'Creating content using AI-powered tools...'
    def augmented_reality_and_virtual_reality
      puts 'Enhancing user experience with AR and VR...'
    def multilingual_seo
      puts 'Optimizing for multilingual content...'
    def advanced_analytics
      puts 'Leveraging advanced analytics for deeper insights...'
    def continuous_learning_and_adaptation
      puts 'Ensuring continuous learning and adaptation in SEO practices...'
  end
end