# frozen_string_literal: true

# Lawyer Assistant - Consolidated legal expertise combining multiple specializations
# Integrates Norwegian legal system (Lovdata.no) with international legal knowledge

require 'yaml'
require 'i18n'
require_relative '../lib/universal_scraper'
require_relative '../lib/rag_engine'
require_relative '../lib/weaviate_integration'

module Assistants
  class Lawyer
    attr_reader :name, :role, :capabilities, :specializations, :lovdata_scraper, :rag_engine

    # Combined knowledge sources from lawyer_assistant.rb and legal_specialist.rb
    KNOWLEDGE_SOURCES = [
      'https://lovdata.no/',
      'https://bufdir.no/',
      'https://lexisnexis.com/',
      'https://westlaw.com/',
      'https://courtlistener.com/',
      'https://scholar.google.com/scholar',
      'https://justia.com/',
      'https://findlaw.com/',
      'https://regjeringen.no/',
      'https://domstol.no/'
    ].freeze

    # Norwegian Legal Specializations (from lawyer_assistant.rb)
    NORWEGIAN_SPECIALIZATIONS = {
      familierett: {
        name: 'Familierett',
        description: 'Family Law - Marriage, divorce, child custody, inheritance',
        keywords: %w[familie skilsmisse foreldrerett barnebidrag arv ektepakt samboer],
        lovdata_sections: %w[ekteskapsloven barnelova arvelova vergemålslova]
      },
      straffrett: {
        name: 'Straffrett', 
        description: 'Criminal Law - Criminal cases, procedures, penalties',
        keywords: %w[straffesak domstol anklage forsvar straff bot fengsel],
        lovdata_sections: %w[straffeloven straffeprosessloven]
      },
      sivilrett: {
        name: 'Sivilrett',
        description: 'Civil Law - Contracts, property, obligations, tort',
        keywords: %w[kontrakt eiendom erstatning avtale mislighold kjøp salg],
        lovdata_sections: %w[avtalelov kjøpsloven skadeserstatningsloven]
      },
      forvaltningsrett: {
        name: 'Forvaltningsrett',
        description: 'Administrative Law - Government decisions, appeals',
        keywords: %w[forvaltning vedtak klage offentlig myndighet fylkesmann],
        lovdata_sections: %w[forvaltningsloven offentlighetsloven]
      },
      selskapsrett: {
        name: 'Selskapsrett',
        description: 'Corporate Law - Company formation, governance, mergers',
        keywords: %w[selskap aksjer styre AS aksjeselskap fusjon oppkjøp],
        lovdata_sections: %w[aksjeloven allmennaksjeloven]
      }
    }.freeze

    # International Legal Subspecialties (from legal_specialist.rb)
    INTERNATIONAL_SUBSPECIALTIES = {
      family: %i[family_law divorce child_custody],
      corporate: %i[corporate_law business_contracts mergers_and_acquisitions],
      criminal: %i[criminal_defense white_collar_crime drug_offenses],
      immigration: %i[immigration_law visa_applications deportation_defense],
      real_estate: %i[property_law real_estate_transactions landlord_tenant_disputes],
      intellectual_property: %i[copyright patent trademark trade_secrets],
      employment: %i[employment_law labor_disputes workplace_rights],
      tax: %i[tax_law tax_planning tax_litigation],
      environmental: %i[environmental_law regulatory_compliance],
      health: %i[healthcare_law medical_malpractice]
    }.freeze

    def initialize(config = {})
      @name = 'Legal Expert'
      @role = 'Comprehensive Legal Assistant and Advisor'
      @capabilities = [
        'Norwegian and international legal research',
        'Contract analysis and drafting',
        'Legal compliance guidance',
        'Case law research',
        'Document review',
        'Legal writing assistance',
        'Regulatory compliance',
        'Cross-jurisdictional legal analysis'
      ]
      @specializations = NORWEGIAN_SPECIALIZATIONS.merge(
        INTERNATIONAL_SUBSPECIALTIES.transform_values { |v| { description: v.join(', ') } }
      )
      
      @language = config[:language] || 'en'
      @jurisdiction = config[:jurisdiction] || 'NO'
      @subspecialty = config[:subspecialty] || :general
      
      initialize_tools
    end

    def process(input, context = {})
      # Determine if this is a Norwegian or international legal query
      jurisdiction = detect_jurisdiction(input) || @jurisdiction
      
      if jurisdiction == 'NO'
        process_norwegian_legal_query(input, context)
      else
        process_international_legal_query(input, context)
      end
    end

    def get_legal_advice(query, specialization = nil)
      specialization ||= detect_specialization(query)
      
      context = build_legal_context(query, specialization)
      research_results = conduct_legal_research(query, specialization)
      
      generate_legal_response(query, context, research_results, specialization)
    end

    def analyze_contract(contract_text, contract_type = 'general')
      analysis = {
        contract_type: contract_type,
        key_clauses: extract_key_clauses(contract_text),
        potential_issues: identify_potential_issues(contract_text),
        recommendations: generate_contract_recommendations(contract_text),
        compliance_check: check_legal_compliance(contract_text, contract_type)
      }
      
      format_contract_analysis(analysis)
    end

    def research_case_law(query, jurisdiction = nil)
      jurisdiction ||= @jurisdiction
      
      case jurisdiction
      when 'NO'
        research_norwegian_case_law(query)
      else
        research_international_case_law(query, jurisdiction)
      end
    end

    private

    def initialize_tools
      @lovdata_scraper = UniversalScraper.new(base_url: 'https://lovdata.no')
      @rag_engine = RagEngine.new
      @weaviate_client = WeaviateIntegration.new if defined?(WeaviateIntegration)
    end

    def detect_jurisdiction(input)
      norwegian_indicators = %w[lovdata lov forskrift norsk norge norwegian]
      
      return 'NO' if norwegian_indicators.any? { |indicator| input.downcase.include?(indicator) }
      
      # Check for other jurisdiction indicators
      return 'US' if input.downcase.match?(/\b(us|usa|american|federal)\b/)
      return 'UK' if input.downcase.match?(/\b(uk|british|england|wales|scotland)\b/)
      return 'EU' if input.downcase.match?(/\b(eu|european union|gdpr)\b/)
      
      nil
    end

    def detect_specialization(query)
      query_lower = query.downcase
      
      # Check Norwegian specializations
      NORWEGIAN_SPECIALIZATIONS.each do |key, spec|
        return key if spec[:keywords].any? { |keyword| query_lower.include?(keyword) }
      end
      
      # Check international specializations
      INTERNATIONAL_SUBSPECIALTIES.each do |key, subspecs|
        return key if subspecs.any? { |subspec| query_lower.include?(subspec.to_s.gsub('_', ' ')) }
      end
      
      :general
    end

    def process_norwegian_legal_query(input, context)
      specialization = detect_specialization(input)
      lovdata_results = @lovdata_scraper.search(input)
      
      response = "**Norwegian Legal Analysis**\n\n"
      response += "**Specialization:** #{NORWEGIAN_SPECIALIZATIONS[specialization][:name]}\n\n"
      
      if lovdata_results&.any?
        response += "**Relevant Legal Sources:**\n"
        lovdata_results.each do |result|
          response += "- #{result[:title]}: #{result[:url]}\n"
        end
        response += "\n"
      end
      
      response += generate_legal_analysis(input, specialization, 'NO')
      response
    end

    def process_international_legal_query(input, context)
      specialization = detect_specialization(input)
      jurisdiction = detect_jurisdiction(input) || 'INTERNATIONAL'
      
      response = "**International Legal Analysis**\n\n"
      response += "**Jurisdiction:** #{jurisdiction}\n"
      response += "**Specialization:** #{specialization.to_s.humanize}\n\n"
      
      response += generate_legal_analysis(input, specialization, jurisdiction)
      response
    end

    def conduct_legal_research(query, specialization)
      results = []
      
      # Search relevant knowledge sources
      KNOWLEDGE_SOURCES.each do |source|
        begin
          search_results = @rag_engine.search(query, source: source)
          results.concat(search_results) if search_results
        rescue => e
          puts "Error searching #{source}: #{e.message}"
        end
      end
      
      results
    end

    def generate_legal_analysis(input, specialization, jurisdiction)
      analysis = <<~ANALYSIS
        **Legal Analysis:**
        
        Based on the query regarding #{specialization}, the following considerations apply:
        
        1. **Primary Legal Framework:** The applicable legal framework depends on the jurisdiction (#{jurisdiction}) and specific circumstances.
        
        2. **Key Considerations:** 
           - Statutory requirements and regulations
           - Relevant case law precedents
           - Procedural requirements
           - Potential legal risks and mitigation strategies
        
        3. **Recommendations:**
           - Consult with a qualified attorney for specific legal advice
           - Review all relevant documentation
           - Consider jurisdiction-specific requirements
           - Ensure compliance with applicable regulations
        
        **Disclaimer:** This analysis is for informational purposes only and does not constitute legal advice. Always consult with a qualified attorney for legal matters.
      ANALYSIS
      
      analysis
    end

    def extract_key_clauses(contract_text)
      # Simple pattern matching for common contract clauses
      clauses = []
      
      clauses << 'Payment terms' if contract_text.match?(/payment|fee|cost|price/i)
      clauses << 'Termination clause' if contract_text.match?(/terminat|end|expir/i)
      clauses << 'Liability limitation' if contract_text.match?(/liabilit|damages|limit/i)
      clauses << 'Confidentiality' if contract_text.match?(/confident|secret|proprietary/i)
      clauses << 'Governing law' if contract_text.match?(/governing|applicable|law|jurisdiction/i)
      
      clauses
    end

    def identify_potential_issues(contract_text)
      issues = []
      
      issues << 'Missing payment terms' unless contract_text.match?(/payment|fee|cost/i)
      issues << 'No termination clause' unless contract_text.match?(/terminat|end/i)
      issues << 'Unclear liability provisions' unless contract_text.match?(/liabilit|damages/i)
      issues << 'Missing governing law clause' unless contract_text.match?(/governing.*law|applicable.*law/i)
      
      issues
    end

    def generate_contract_recommendations(contract_text)
      recommendations = [
        'Review all terms carefully with legal counsel',
        'Ensure all parties understand their obligations',
        'Verify compliance with applicable laws',
        'Consider including dispute resolution clauses'
      ]
      
      recommendations
    end

    def check_legal_compliance(contract_text, contract_type)
      compliance_items = []
      
      case contract_type
      when 'employment'
        compliance_items << 'Wage and hour law compliance'
        compliance_items << 'Non-discrimination provisions'
        compliance_items << 'Workplace safety requirements'
      when 'real_estate'
        compliance_items << 'Property disclosure requirements'
        compliance_items << 'Zoning compliance'
        compliance_items << 'Environmental regulations'
      else
        compliance_items << 'General contract law requirements'
        compliance_items << 'Consumer protection laws (if applicable)'
      end
      
      compliance_items
    end

    def format_contract_analysis(analysis)
      output = "**Contract Analysis Report**\n\n"
      output += "**Contract Type:** #{analysis[:contract_type].humanize}\n\n"
      
      output += "**Key Clauses Identified:**\n"
      analysis[:key_clauses].each { |clause| output += "- #{clause}\n" }
      output += "\n"
      
      if analysis[:potential_issues].any?
        output += "**Potential Issues:**\n"
        analysis[:potential_issues].each { |issue| output += "- #{issue}\n" }
        output += "\n"
      end
      
      output += "**Recommendations:**\n"
      analysis[:recommendations].each { |rec| output += "- #{rec}\n" }
      output += "\n"
      
      output += "**Compliance Considerations:**\n"
      analysis[:compliance_check].each { |item| output += "- #{item}\n" }
      
      output
    end

    def research_norwegian_case_law(query)
      # Placeholder for Norwegian case law research
      "Norwegian case law research for: #{query}\n\nConsult Lovdata.no for current cases and legal precedents."
    end

    def research_international_case_law(query, jurisdiction)
      # Placeholder for international case law research  
      "International case law research (#{jurisdiction}) for: #{query}\n\nConsult relevant legal databases for current cases."
    end

    def build_legal_context(query, specialization)
      {
        query: query,
        specialization: specialization,
        jurisdiction: @jurisdiction,
        timestamp: Time.now,
        language: @language
      }
    end

    def generate_legal_response(query, context, research_results, specialization)
      response = "**Legal Research Response**\n\n"
      response += "**Query:** #{query}\n"
      response += "**Specialization:** #{specialization}\n"
      response += "**Jurisdiction:** #{context[:jurisdiction]}\n\n"
      
      if research_results.any?
        response += "**Research Results:**\n"
        research_results.first(5).each do |result|
          response += "- #{result[:title] || result[:summary] || result.to_s}\n"
        end
        response += "\n"
      end
      
      response += "**Legal Analysis:** [Detailed analysis would be provided here based on research]\n\n"
      response += "**Disclaimer:** This is for informational purposes only. Consult qualified legal counsel."
      
      response
    end
  end
end