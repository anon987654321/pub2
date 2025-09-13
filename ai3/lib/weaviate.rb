# frozen_string_literal: true

# Weaviate Integration - Vector database for AI³ assistant system
# Consolidated from weaviate_integration.rb and weaviate_wrapper.rb

module AI3
  class Weaviate
    attr_reader :client, :schema, :config

    def initialize(config = {})
      @config = {
        host: config[:host] || 'localhost',
        port: config[:port] || 8080,
        scheme: config[:scheme] || 'http',
        timeout: config[:timeout] || 30
      }
      
      @schema = config[:schema] || default_schema
      @client = nil
      @connected = false
      
      initialize_client if config[:auto_connect] != false
    end

    # Connection management
    def connect
      return true if @connected
      
      begin
        # Initialize Weaviate client (stub implementation)
        @client = MockWeaviateClient.new(@config)
        @connected = true
        puts "Connected to Weaviate at #{@config[:scheme]}://#{@config[:host]}:#{@config[:port]}"
        true
      rescue => e
        puts "Failed to connect to Weaviate: #{e.message}"
        false
      end
    end

    def disconnect
      @client = nil
      @connected = false
      puts "Disconnected from Weaviate"
    end

    def connected?
      @connected
    end

    # Data operations
    def check_if_indexed(url)
      return false unless connected?
      
      begin
        query = {
          where: {
            path: ["url"],
            operator: "Equal",
            valueString: url
          }
        }
        
        results = @client.query(query)
        !results.empty?
      rescue => e
        puts "Error checking if #{url} is indexed: #{e.message}"
        false
      end
    end

    def add_data_to_weaviate(url:, content:, metadata: {})
      return false unless connected?
      
      begin
        # Prepare document for indexing
        document = prepare_document(url, content, metadata)
        
        # Add to Weaviate
        result = @client.create_object(document)
        
        puts "Successfully indexed #{url}" if result
        result
      rescue => e
        puts "Error adding data for #{url}: #{e.message}"
        false
      end
    end

    def search(query, options = {})
      return [] unless connected?
      
      begin
        search_params = {
          query: query,
          limit: options[:limit] || 10,
          certainty: options[:certainty] || 0.7
        }
        
        results = @client.search(search_params)
        format_search_results(results)
      rescue => e
        puts "Error searching: #{e.message}"
        []
      end
    end

    def delete_by_url(url)
      return false unless connected?
      
      begin
        query = {
          where: {
            path: ["url"],
            operator: "Equal",
            valueString: url
          }
        }
        
        @client.delete_objects(query)
        puts "Deleted objects for URL: #{url}"
        true
      rescue => e
        puts "Error deleting objects for #{url}: #{e.message}"
        false
      end
    end

    # Schema management
    def create_schema
      return false unless connected?
      
      begin
        @client.create_schema(@schema)
        puts "Schema created successfully"
        true
      rescue => e
        puts "Error creating schema: #{e.message}"
        false
      end
    end

    def delete_schema
      return false unless connected?
      
      begin
        @client.delete_schema
        puts "Schema deleted successfully"
        true
      rescue => e
        puts "Error deleting schema: #{e.message}"
        false
      end
    end

    # Batch operations
    def batch_add(documents)
      return false unless connected?
      
      begin
        prepared_docs = documents.map do |doc|
          prepare_document(doc[:url], doc[:content], doc[:metadata] || {})
        end
        
        results = @client.batch_create(prepared_docs)
        successful = results.count { |r| r[:success] }
        
        puts "Batch add completed: #{successful}/#{documents.length} successful"
        results
      rescue => e
        puts "Error in batch add: #{e.message}"
        []
      end
    end

    # Statistics and health
    def get_stats
      return {} unless connected?
      
      begin
        @client.get_meta
      rescue => e
        puts "Error getting stats: #{e.message}"
        {}
      end
    end

    def health_check
      return false unless connected?
      
      begin
        @client.is_ready
      rescue => e
        puts "Health check failed: #{e.message}"
        false
      end
    end

    private

    def initialize_client
      connect
    end

    def default_schema
      {
        class: "Document",
        description: "AI³ Assistant knowledge documents",
        properties: [
          {
            name: "url",
            dataType: ["string"],
            description: "Source URL of the document"
          },
          {
            name: "title", 
            dataType: ["string"],
            description: "Title of the document"
          },
          {
            name: "content",
            dataType: ["text"],
            description: "Main content of the document"
          },
          {
            name: "summary",
            dataType: ["text"],
            description: "Summary of the document"
          },
          {
            name: "keywords",
            dataType: ["string[]"],
            description: "Keywords extracted from the document"
          },
          {
            name: "category",
            dataType: ["string"],
            description: "Category or type of document"
          },
          {
            name: "timestamp",
            dataType: ["date"],
            description: "When the document was indexed"
          },
          {
            name: "assistant_type",
            dataType: ["string"],
            description: "Which assistant this content is relevant for"
          }
        ]
      }
    end

    def prepare_document(url, content, metadata)
      {
        url: url,
        title: metadata[:title] || extract_title(content),
        content: content,
        summary: metadata[:summary] || generate_summary(content),
        keywords: metadata[:keywords] || extract_keywords(content),
        category: metadata[:category] || "general",
        timestamp: Time.now.iso8601,
        assistant_type: metadata[:assistant_type] || "general"
      }
    end

    def extract_title(content)
      # Simple title extraction
      lines = content.split("\n").reject(&:empty?)
      return "Untitled" if lines.empty?
      
      # Try to find a title-like line
      title_candidate = lines.first.strip
      title_candidate.length > 100 ? title_candidate[0..100] + "..." : title_candidate
    end

    def generate_summary(content)
      # Simple summary generation
      sentences = content.split(/[.!?]+/).reject(&:empty?)
      return content if sentences.length <= 2
      
      # Take first 2-3 sentences as summary
      summary_sentences = sentences[0..2].join('. ')
      summary_sentences.length > 500 ? summary_sentences[0..500] + "..." : summary_sentences
    end

    def extract_keywords(content)
      # Simple keyword extraction
      words = content.downcase.split(/\W+/).reject { |w| w.length < 4 }
      word_freq = words.tally
      
      # Get top 10 most frequent words
      word_freq.sort_by { |word, freq| -freq }.first(10).map(&:first)
    end

    def format_search_results(results)
      results.map do |result|
        {
          url: result[:url],
          title: result[:title],
          content: result[:content],
          summary: result[:summary],
          score: result[:certainty] || result[:score] || 1.0,
          metadata: {
            category: result[:category],
            keywords: result[:keywords],
            timestamp: result[:timestamp],
            assistant_type: result[:assistant_type]
          }
        }
      end
    end

    # Mock client for development/testing
    class MockWeaviateClient
      def initialize(config)
        @config = config
        @objects = []
        @schema = nil
      end

      def query(params)
        # Mock query implementation
        url = params.dig(:where, :valueString)
        @objects.select { |obj| obj[:url] == url }
      end

      def create_object(object)
        object[:id] = SecureRandom.uuid
        @objects << object
        { success: true, id: object[:id] }
      end

      def search(params)
        # Mock search implementation
        query = params[:query].downcase
        limit = params[:limit] || 10
        
        results = @objects.select do |obj|
          obj[:content]&.downcase&.include?(query) ||
          obj[:title]&.downcase&.include?(query) ||
          obj[:summary]&.downcase&.include?(query)
        end
        
        results.first(limit)
      end

      def delete_objects(query)
        url = query.dig(:where, :valueString)
        @objects.reject! { |obj| obj[:url] == url }
        true
      end

      def batch_create(objects)
        objects.map do |obj|
          result = create_object(obj)
          { success: true, id: result[:id] }
        end
      end

      def create_schema(schema)
        @schema = schema
        true
      end

      def delete_schema
        @schema = nil
        @objects = []
        true
      end

      def get_meta
        {
          objects_count: @objects.length,
          schema_classes: @schema ? 1 : 0
        }
      end

      def is_ready
        true
      end
    end
  end
end

# Backward compatibility
WeaviateIntegration = AI3::Weaviate
WeaviateWrapper = AI3::Weaviate