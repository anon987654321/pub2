# frozen_string_literal: true

# Personal Safety Assistant - Focus on personal security, situational awareness, and safety
# Consolidated from personal_assistant.rb with enhanced safety features

require_relative '../lib/context_manager'
require_relative '../lib/memory_manager'

module Assistants
  class PersonalSafety
    attr_reader :name, :role, :capabilities
    attr_accessor :user_profile, :environment_monitor, :emergency_contacts

    def initialize(config = {})
      @name = 'Personal Safety Assistant'
      @role = 'Personal Security and Safety Advisor'
      @capabilities = [
        'Situational awareness monitoring',
        'Emergency response guidance',
        'Personal safety planning',
        'Threat assessment',
        'Safety education and tips',
        'Emergency contact management',
        'Location safety analysis',
        'Personal security recommendations'
      ]
      
      @user_profile = config[:user_profile] || {}
      @emergency_contacts = config[:emergency_contacts] || []
      @environment_monitor = EnvironmentMonitor.new
      @context_manager = ContextManager.new
      @memory_manager = MemoryManager.new
    end

    def process(input, context = {})
      safety_type = detect_safety_concern(input)
      
      case safety_type
      when :emergency
        handle_emergency_situation(input, context)
      when :threat_assessment
        assess_threat(input, context)
      when :safety_planning
        provide_safety_planning(input, context)
      when :location_safety
        analyze_location_safety(input, context)
      when :personal_security
        provide_security_advice(input, context)
      else
        provide_general_safety_guidance(input, context)
      end
    end

    # Emergency Response
    def handle_emergency_situation(input, context)
      response = "**🚨 EMERGENCY RESPONSE PROTOCOL**\n\n"
      
      # Immediate actions
      response += "**Immediate Actions:**\n"
      response += "1. **Call Emergency Services:** Dial 911 (US), 112 (EU), or local emergency number\n"
      response += "2. **Ensure Personal Safety:** Move to a safe location if possible\n"
      response += "3. **Contact Emergency Contacts:** Notify your emergency contacts\n\n"
      
      # Emergency contacts
      if @emergency_contacts.any?
        response += "**Your Emergency Contacts:**\n"
        @emergency_contacts.each_with_index do |contact, idx|
          response += "#{idx + 1}. #{contact[:name]}: #{contact[:phone]}\n"
        end
        response += "\n"
      end
      
      # Specific emergency guidance
      response += get_specific_emergency_guidance(input)
      
      response += "\n**Remember:** Your safety is the top priority. Don't hesitate to contact authorities."
      response
    end

    # Threat Assessment
    def assess_threat(input, context)
      threat_level = analyze_threat_level(input)
      
      response = "**🔍 THREAT ASSESSMENT**\n\n"
      response += "**Threat Level:** #{threat_level[:level]}\n"
      response += "**Assessment:** #{threat_level[:description]}\n\n"
      
      response += "**Recommended Actions:**\n"
      threat_level[:actions].each_with_index do |action, idx|
        response += "#{idx + 1}. #{action}\n"
      end
      
      response += "\n**Situational Awareness Tips:**\n"
      response += "- Trust your instincts\n"
      response += "- Be aware of your surroundings\n"
      response += "- Have exit strategies\n"
      response += "- Keep emergency contacts accessible\n"
      
      response
    end

    # Safety Planning
    def provide_safety_planning(input, context)
      response = "**🛡️ PERSONAL SAFETY PLANNING**\n\n"
      
      plan_type = detect_safety_plan_type(input)
      
      case plan_type
      when :travel
        response += generate_travel_safety_plan(input)
      when :home
        response += generate_home_safety_plan(input)
      when :workplace
        response += generate_workplace_safety_plan(input)
      when :dating
        response += generate_dating_safety_plan(input)
      else
        response += generate_general_safety_plan(input)
      end
      
      response
    end

    # Location Safety Analysis
    def analyze_location_safety(input, context)
      location = extract_location(input)
      
      response = "**📍 LOCATION SAFETY ANALYSIS**\n\n"
      response += "**Location:** #{location}\n\n"
      
      safety_factors = [
        "Crime statistics and trends",
        "Emergency services accessibility",
        "Transportation safety",
        "Lighting and visibility",
        "Population density and activity levels",
        "Weather and environmental factors"
      ]
      
      response += "**Safety Factors to Consider:**\n"
      safety_factors.each_with_index do |factor, idx|
        response += "#{idx + 1}. #{factor}\n"
      end
      
      response += "\n**General Safety Recommendations:**\n"
      response += "- Research the area beforehand\n"
      response += "- Share your location with trusted contacts\n"
      response += "- Have local emergency numbers saved\n"
      response += "- Plan your routes and transportation\n"
      response += "- Stay aware of local customs and laws\n"
      
      response
    end

    # Personal Security Advice
    def provide_security_advice(input, context)
      response = "**🔐 PERSONAL SECURITY RECOMMENDATIONS**\n\n"
      
      security_areas = {
        digital: [
          "Use strong, unique passwords",
          "Enable two-factor authentication",
          "Keep software updated",
          "Be cautious with public Wi-Fi",
          "Regularly backup important data"
        ],
        physical: [
          "Vary your daily routines",
          "Be aware of who's around you",
          "Secure your home and vehicle",
          "Don't share personal information publicly",
          "Trust your instincts about people and situations"
        ],
        financial: [
          "Monitor your accounts regularly",
          "Use secure payment methods",
          "Don't carry excessive cash",
          "Be cautious of scams and fraud",
          "Protect your personal information"
        ]
      }
      
      security_type = detect_security_type(input)
      
      if security_type && security_areas[security_type]
        response += "**#{security_type.to_s.capitalize} Security:**\n"
        security_areas[security_type].each_with_index do |tip, idx|
          response += "#{idx + 1}. #{tip}\n"
        end
      else
        response += "**Comprehensive Security Checklist:**\n"
        security_areas.each do |category, tips|
          response += "\n**#{category.to_s.capitalize} Security:**\n"
          tips.each { |tip| response += "- #{tip}\n" }
        end
      end
      
      response
    end

    # Emergency Contact Management
    def add_emergency_contact(name, phone, relationship = nil)
      contact = {
        name: name,
        phone: phone,
        relationship: relationship,
        added_at: Time.now
      }
      
      @emergency_contacts << contact
      "Emergency contact added: #{name} (#{phone})"
    end

    def list_emergency_contacts
      return "No emergency contacts configured." if @emergency_contacts.empty?
      
      response = "**Emergency Contacts:**\n"
      @emergency_contacts.each_with_index do |contact, idx|
        response += "#{idx + 1}. #{contact[:name]}: #{contact[:phone]}"
        response += " (#{contact[:relationship]})" if contact[:relationship]
        response += "\n"
      end
      
      response
    end

    private

    def detect_safety_concern(input)
      input_lower = input.downcase
      
      return :emergency if input_lower.match?(/\b(emergency|help|danger|attack|threat|911)\b/)
      return :threat_assessment if input_lower.match?(/\b(threat|suspicious|assess|evaluate)\b/)
      return :safety_planning if input_lower.match?(/\b(plan|prepare|safety plan|travel plan)\b/)
      return :location_safety if input_lower.match?(/\b(location|area|neighborhood|safe place)\b/)
      return :personal_security if input_lower.match?(/\b(security|protect|secure|privacy)\b/)
      
      :general
    end

    def analyze_threat_level(input)
      input_lower = input.downcase
      
      high_risk_indicators = %w[weapon violence stalking following threatening]
      medium_risk_indicators = %w[suspicious uncomfortable unsafe uncertain]
      
      if high_risk_indicators.any? { |indicator| input_lower.include?(indicator) }
        {
          level: "HIGH",
          description: "Immediate safety concern identified",
          actions: [
            "Contact law enforcement immediately",
            "Move to a safe location",
            "Alert trusted contacts",
            "Document the situation if safe to do so"
          ]
        }
      elsif medium_risk_indicators.any? { |indicator| input_lower.include?(indicator) }
        {
          level: "MEDIUM",
          description: "Potentially concerning situation",
          actions: [
            "Increase situational awareness",
            "Inform someone of your location",
            "Have exit strategy ready",
            "Consider removing yourself from situation"
          ]
        }
      else
        {
          level: "LOW",
          description: "General safety inquiry",
          actions: [
            "Maintain normal safety precautions",
            "Stay aware of surroundings",
            "Follow standard safety practices"
          ]
        }
      end
    end

    def detect_safety_plan_type(input)
      input_lower = input.downcase
      
      return :travel if input_lower.match?(/\b(travel|trip|vacation|journey)\b/)
      return :home if input_lower.match?(/\b(home|house|residence)\b/)
      return :workplace if input_lower.match?(/\b(work|office|job|workplace)\b/)
      return :dating if input_lower.match?(/\b(date|dating|meeting someone)\b/)
      
      :general
    end

    def generate_travel_safety_plan(input)
      "**Travel Safety Plan:**\n" +
      "1. Research your destination\n" +
      "2. Share itinerary with trusted contacts\n" +
      "3. Register with embassy if traveling internationally\n" +
      "4. Have emergency contacts and local numbers\n" +
      "5. Keep copies of important documents\n" +
      "6. Purchase travel insurance\n" +
      "7. Stay aware of local laws and customs\n" +
      "8. Have communication plan\n"
    end

    def generate_home_safety_plan(input)
      "**Home Safety Plan:**\n" +
      "1. Install quality locks and security system\n" +
      "2. Know your neighbors\n" +
      "3. Have emergency supply kit\n" +
      "4. Plan escape routes for emergencies\n" +
      "5. Keep emergency numbers accessible\n" +
      "6. Regular safety equipment maintenance\n" +
      "7. Be cautious about sharing personal information\n"
    end

    def generate_workplace_safety_plan(input)
      "**Workplace Safety Plan:**\n" +
      "1. Know emergency procedures and exits\n" +
      "2. Report safety concerns to management\n" +
      "3. Be aware of workplace policies\n" +
      "4. Maintain professional boundaries\n" +
      "5. Document any concerning incidents\n" +
      "6. Have personal emergency contacts updated\n"
    end

    def generate_dating_safety_plan(input)
      "**Dating Safety Plan:**\n" +
      "1. Meet in public places initially\n" +
      "2. Drive yourself or arrange own transportation\n" +
      "3. Tell someone where you're going\n" +
      "4. Trust your instincts\n" +
      "5. Don't share personal information too quickly\n" +
      "6. Stay sober and alert\n" +
      "7. Have exit strategy\n"
    end

    def generate_general_safety_plan(input)
      "**General Safety Plan:**\n" +
      "1. Maintain situational awareness\n" +
      "2. Trust your instincts\n" +
      "3. Have emergency contacts readily available\n" +
      "4. Know basic self-defense techniques\n" +
      "5. Keep emergency supplies\n" +
      "6. Stay informed about local safety conditions\n" +
      "7. Practice emergency scenarios\n"
    end

    def detect_security_type(input)
      input_lower = input.downcase
      
      return :digital if input_lower.match?(/\b(digital|online|cyber|password|hack)\b/)
      return :physical if input_lower.match?(/\b(physical|personal|body|attack)\b/)
      return :financial if input_lower.match?(/\b(financial|money|scam|fraud|identity)\b/)
      
      nil
    end

    def get_specific_emergency_guidance(input)
      input_lower = input.downcase
      
      if input_lower.match?(/\b(medical|health|injury|accident)\b/)
        return "**Medical Emergency:**\n- Call emergency medical services\n- Provide first aid if trained\n- Don't move injured person unless in immediate danger\n"
      elsif input_lower.match?(/\b(fire|smoke|burn)\b/)
        return "**Fire Emergency:**\n- Call fire department\n- Evacuate immediately\n- Stay low to avoid smoke\n- Don't use elevators\n"
      elsif input_lower.match?(/\b(crime|violence|attack|assault)\b/)
        return "**Crime/Violence:**\n- Call police immediately\n- Get to safety\n- Preserve evidence if possible\n- Seek medical attention if needed\n"
      else
        return "**General Emergency:**\n- Call appropriate emergency services\n- Follow dispatcher instructions\n- Remain calm and provide clear information\n"
      end
    end

    def extract_location(input)
      # Simple location extraction - in a real implementation, this would be more sophisticated
      location_match = input.match(/(?:in|at|to|from)\s+([A-Z][a-z\s,]+)/i)
      location_match ? location_match[1].strip : "specified location"
    end

    def provide_general_safety_guidance(input, context)
      "**🛡️ GENERAL SAFETY GUIDANCE**\n\n" +
      "**Core Safety Principles:**\n" +
      "1. **Situational Awareness:** Stay alert and aware of your surroundings\n" +
      "2. **Trust Your Instincts:** If something feels wrong, it probably is\n" +
      "3. **Communication:** Keep others informed of your whereabouts\n" +
      "4. **Preparation:** Have emergency plans and contacts ready\n" +
      "5. **Avoidance:** The best defense is avoiding dangerous situations\n\n" +
      "**Emergency Numbers:** Keep local emergency services numbers easily accessible\n" +
      "**Documentation:** Record any concerning incidents or interactions\n\n" +
      "Ask me about specific safety topics like travel safety, home security, personal protection, or emergency planning."
    end

    # Environment monitoring class placeholder
    class EnvironmentMonitor
      def initialize
        # Placeholder for environment monitoring functionality
      end

      def analyze(options = {})
        # Placeholder for environmental analysis
      end

      def real_time_alerts
        # Placeholder for real-time alert system
        []
      end
    end
  end
end