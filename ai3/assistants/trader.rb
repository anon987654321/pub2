
# frozen_string_literal: true

# Trading Assistant - Comprehensive financial trading and market analysis
# Consolidated from trader.rb and trading_assistant.rb

require 'yaml'
require 'json' 
require 'logger'
require_relative '../lib/query_cache'
require_relative '../lib/rag_engine'

module Assistants
  class Trader
    attr_reader :name, :role, :capabilities

    # Trading Knowledge Sources
    KNOWLEDGE_SOURCES = [
      'https://www.investopedia.com/',
      'https://finance.yahoo.com/',
      'https://www.bloomberg.com/',
      'https://www.marketwatch.com/',
      'https://coinmarketcap.com/',
      'https://tradingview.com/',
      'https://seekingalpha.com/',
      'https://www.sec.gov/investor'
    ].freeze

    TRADING_STRATEGIES = [
      'day_trading',
      'swing_trading', 
      'position_trading',
      'scalping',
      'arbitrage',
      'momentum_trading',
      'value_investing',
      'technical_analysis',
      'fundamental_analysis'
    ].freeze

    def initialize(config = {})
      @name = 'Trading Expert'
      @role = 'Financial Trading and Market Analysis Assistant'
      @capabilities = [
        'Market analysis and research',
        'Technical analysis and charting',
        'Risk assessment and management',
        'Portfolio optimization',
        'Cryptocurrency analysis',
        'Trading strategy development',
        'Financial news analysis',
        'Investment recommendations'
      ]

      @config = config
      @market_data_cache = QueryCache.new(ttl: 300) # 5-minute cache
      @rag_engine = RagEngine.new
      @logger = Logger.new(STDOUT)
      
      initialize_trading_systems
    end

    def process(input, context = {})
      trading_intent = classify_trading_intent(input)

      case trading_intent
      when :market_analysis
        analyze_market(input, context)
      when :technical_analysis
        perform_technical_analysis(input, context)
      when :risk_assessment
        assess_risk(input, context)
      when :portfolio_optimization
        optimize_portfolio(input, context)
      when :cryptocurrency_analysis
        analyze_cryptocurrency(input, context)
      when :trading_strategy
        suggest_trading_strategy(input, context)
      when :news_analysis
        analyze_financial_news(input, context)
      else
        general_trading_advice(input, context)
      end
    end

    # Market Analysis
    def analyze_market(input, context)
      symbol = extract_symbol(input)
      
      response = "**📈 MARKET ANALYSIS**\n\n"
      
      if symbol
        response += "**Symbol:** #{symbol.upcase}\n\n"
        response += analyze_specific_asset(symbol)
      else
        response += analyze_general_market(input)
      end
      
      response += "\n**Market Factors to Consider:**\n"
      market_factors = [
        "Economic indicators and news",
        "Company earnings and fundamentals",
        "Technical indicators and chart patterns",
        "Market sentiment and volume",
        "Global events and political factors",
        "Sector performance and trends"
      ]
      
      market_factors.each { |factor| response += "- #{factor}\n" }
      
      response += "\n**⚠️ Disclaimer:** This analysis is for educational purposes only. Not financial advice."
      response
    end

    # Technical Analysis
    def perform_technical_analysis(input, context)
      symbol = extract_symbol(input)
      timeframe = extract_timeframe(input) || '1D'
      
      response = "**📊 TECHNICAL ANALYSIS**\n\n"
      
      if symbol
        response += "**Symbol:** #{symbol.upcase}\n"
        response += "**Timeframe:** #{timeframe}\n\n"
      end
      
      response += "**Technical Indicators:**\n"
      
      technical_indicators = {
        "Moving Averages" => [
          "Simple Moving Average (SMA)",
          "Exponential Moving Average (EMA)",
          "Moving Average Convergence Divergence (MACD)"
        ],
        "Momentum Indicators" => [
          "Relative Strength Index (RSI)",
          "Stochastic Oscillator",
          "Williams %R"
        ],
        "Volume Indicators" => [
          "Volume Moving Average",
          "On-Balance Volume (OBV)",
          "Volume Rate of Change"
        ],
        "Volatility Indicators" => [
          "Bollinger Bands",
          "Average True Range (ATR)",
          "Volatility Index"
        ]
      }
      
      technical_indicators.each do |category, indicators|
        response += "\n**#{category}:**\n"
        indicators.each { |indicator| response += "- #{indicator}\n" }
      end
      
      response += "\n**Chart Pattern Analysis:**\n"
      chart_patterns = [
        "Support and Resistance levels",
        "Trend lines and channels",
        "Head and Shoulders patterns",
        "Double tops and bottoms",
        "Triangle patterns",
        "Flag and pennant patterns"
      ]
      
      chart_patterns.each { |pattern| response += "- #{pattern}\n" }
      
      response
    end

    # Risk Assessment
    def assess_risk(input, context)
      response = "**⚠️ RISK ASSESSMENT**\n\n"
      
      risk_factors = {
        "Market Risk" => [
          "Overall market volatility",
          "Economic downturns",
          "Interest rate changes",
          "Inflation effects"
        ],
        "Company-Specific Risk" => [
          "Business model viability",
          "Management quality",
          "Competitive position",
          "Financial health"
        ],
        "Technical Risk" => [
          "Liquidity risk",
          "Execution risk",
          "Platform reliability",
          "Cybersecurity threats"
        ],
        "Regulatory Risk" => [
          "Government policy changes",
          "Tax law modifications",
          "Industry regulations",
          "International trade policies"
        ]
      }
      
      risk_factors.each do |category, risks|
        response += "**#{category}:**\n"
        risks.each { |risk| response += "- #{risk}\n" }
        response += "\n"
      end
      
      response += "**Risk Management Strategies:**\n"
      risk_strategies = [
        "Diversification across assets and sectors",
        "Position sizing and stop-loss orders",
        "Regular portfolio rebalancing",
        "Hedging with derivatives",
        "Maintaining emergency reserves",
        "Continuous monitoring and adjustment"
      ]
      
      risk_strategies.each_with_index { |strategy, idx| response += "#{idx + 1}. #{strategy}\n" }
      
      response
    end

    # Portfolio Optimization
    def optimize_portfolio(input, context)
      response = "**💼 PORTFOLIO OPTIMIZATION**\n\n"
      
      response += "**Asset Allocation Principles:**\n"
      allocation_principles = [
        "Age-based allocation (100 - age = stock percentage)",
        "Risk tolerance assessment",
        "Time horizon consideration",
        "Geographic diversification",
        "Sector diversification",
        "Market cap diversification"
      ]
      
      allocation_principles.each { |principle| response += "- #{principle}\n" }
      
      response += "\n**Sample Asset Allocations:**\n\n"
      
      portfolios = {
        "Conservative (Low Risk)" => {
          "Bonds/Fixed Income" => "60%",
          "Large Cap Stocks" => "25%",
          "REITs" => "10%",
          "Cash/Money Market" => "5%"
        },
        "Moderate (Medium Risk)" => {
          "Large Cap Stocks" => "40%",
          "Bonds/Fixed Income" => "35%",
          "International Stocks" => "15%",
          "Small Cap Stocks" => "10%"
        },
        "Aggressive (High Risk)" => {
          "Large Cap Stocks" => "50%",
          "Small Cap Stocks" => "20%",
          "International Stocks" => "20%",
          "Growth Stocks" => "10%"
        }
      }
      
      portfolios.each do |type, allocation|
        response += "**#{type}:**\n"
        allocation.each { |asset, percentage| response += "- #{asset}: #{percentage}\n" }
        response += "\n"
      end
      
      response += "**Rebalancing Guidelines:**\n"
      rebalancing = [
        "Review portfolio quarterly",
        "Rebalance when allocation drifts >5%",
        "Consider tax implications",
        "Use new contributions for rebalancing",
        "Monitor expense ratios and fees"
      ]
      
      rebalancing.each { |guideline| response += "- #{guideline}\n" }
      
      response
    end

    # Cryptocurrency Analysis
    def analyze_cryptocurrency(input, context)
      crypto_symbol = extract_crypto_symbol(input)
      
      response = "**₿ CRYPTOCURRENCY ANALYSIS**\n\n"
      
      if crypto_symbol
        response += "**Cryptocurrency:** #{crypto_symbol.upcase}\n\n"
      end
      
      response += "**Crypto Market Factors:**\n"
      crypto_factors = [
        "Market sentiment and adoption",
        "Regulatory developments",
        "Technology updates and improvements",
        "Partnership announcements",
        "Mining difficulty and network health",
        "Institutional investment flows"
      ]
      
      crypto_factors.each { |factor| response += "- #{factor}\n" }
      
      response += "\n**Crypto Risk Considerations:**\n"
      crypto_risks = [
        "High volatility and price swings",
        "Regulatory uncertainty",
        "Technology and security risks",
        "Market manipulation potential",
        "Liquidity risks in smaller coins",
        "Environmental concerns (for PoW coins)"
      ]
      
      crypto_risks.each { |risk| response += "- #{risk}\n" }
      
      response += "\n**Popular Cryptocurrencies:**\n"
      popular_cryptos = [
        "Bitcoin (BTC) - Digital gold, store of value",
        "Ethereum (ETH) - Smart contracts platform",
        "Binance Coin (BNB) - Exchange utility token",
        "Cardano (ADA) - Proof-of-stake blockchain",
        "Solana (SOL) - High-speed blockchain",
        "Polkadot (DOT) - Interoperability protocol"
      ]
      
      popular_cryptos.each { |crypto| response += "- #{crypto}\n" }
      
      response
    end

    # Trading Strategy Suggestions
    def suggest_trading_strategy(input, context)
      strategy_type = extract_strategy_type(input)
      
      response = "**📋 TRADING STRATEGY RECOMMENDATIONS**\n\n"
      
      if strategy_type
        response += generate_specific_strategy(strategy_type)
      else
        response += generate_general_strategies
      end
      
      response += "\n**Strategy Implementation Tips:**\n"
      implementation_tips = [
        "Start with paper trading to test strategies",
        "Define clear entry and exit rules",
        "Set stop-loss and take-profit levels",
        "Maintain a trading journal",
        "Monitor performance metrics",
        "Adjust strategies based on market conditions"
      ]
      
      implementation_tips.each { |tip| response += "- #{tip}\n" }
      
      response
    end

    private

    def initialize_trading_systems
      @risk_manager = RiskManager.new
      @portfolio_tracker = PortfolioTracker.new
      @technical_indicators = TechnicalIndicators.new
    end

    def classify_trading_intent(input)
      input_lower = input.downcase
      
      return :market_analysis if input_lower.match?(/\b(market|analysis|price|chart)\b/)
      return :technical_analysis if input_lower.match?(/\b(technical|indicator|rsi|macd|moving average)\b/)
      return :risk_assessment if input_lower.match?(/\b(risk|volatility|assessment|manage)\b/)
      return :portfolio_optimization if input_lower.match?(/\b(portfolio|allocation|diversify|optimize)\b/)
      return :cryptocurrency_analysis if input_lower.match?(/\b(crypto|bitcoin|ethereum|blockchain)\b/)
      return :trading_strategy if input_lower.match?(/\b(strategy|trading|buy|sell|position)\b/)
      return :news_analysis if input_lower.match?(/\b(news|earnings|announcement|event)\b/)
      
      :general
    end

    def extract_symbol(input)
      # Simple symbol extraction - look for ticker symbols
      symbol_match = input.match(/\b([A-Z]{1,5})\b/)
      symbol_match ? symbol_match[1] : nil
    end

    def extract_crypto_symbol(input)
      crypto_symbols = %w[BTC ETH ADA SOL DOT LINK UNI AAVE MATIC AVAX]
      input_upper = input.upcase
      
      crypto_symbols.find { |symbol| input_upper.include?(symbol) }
    end

    def extract_timeframe(input)
      timeframes = { '1m' => '1 minute', '5m' => '5 minutes', '1h' => '1 hour', '1d' => '1 day', '1w' => '1 week' }
      
      timeframes.keys.find { |tf| input.downcase.include?(tf) }
    end

    def extract_strategy_type(input)
      TRADING_STRATEGIES.find { |strategy| input.downcase.include?(strategy.gsub('_', ' ')) }
    end

    def analyze_specific_asset(symbol)
      "**Analysis for #{symbol.upcase}:**\n" +
      "- Current price trends and momentum\n" +
      "- Trading volume and liquidity\n" +
      "- Key support and resistance levels\n" +
      "- Recent news and developments\n" +
      "- Analyst ratings and price targets\n\n"
    end

    def analyze_general_market(input)
      "**General Market Overview:**\n" +
      "- Major market indices performance\n" +
      "- Sector rotation and leadership\n" +
      "- Economic indicators and data\n" +
      "- Central bank policies and interest rates\n" +
      "- Geopolitical events and market impact\n\n"
    end

    def generate_specific_strategy(strategy_type)
      case strategy_type
      when 'day_trading'
        "**Day Trading Strategy:**\n" +
        "- Trade within single trading session\n" +
        "- Focus on high-volume, liquid stocks\n" +
        "- Use technical analysis for entry/exit\n" +
        "- Maintain strict risk management\n" +
        "- Monitor market news throughout day\n\n"
      when 'swing_trading'
        "**Swing Trading Strategy:**\n" +
        "- Hold positions for days to weeks\n" +
        "- Identify trend reversals and continuations\n" +
        "- Use combination of technical and fundamental analysis\n" +
        "- Set wider stop-losses for volatility\n" +
        "- Focus on stocks with clear catalysts\n\n"
      else
        "**#{strategy_type.humanize} Strategy:**\n" +
        "- Research and implement proven methodologies\n" +
        "- Adapt to current market conditions\n" +
        "- Maintain consistent risk management\n" +
        "- Monitor and adjust as needed\n\n"
      end
    end

    def generate_general_strategies
      "**Popular Trading Strategies:**\n\n" +
      "1. **Trend Following:** Trade in direction of prevailing trend\n" +
      "2. **Mean Reversion:** Buy oversold, sell overbought assets\n" +
      "3. **Breakout Trading:** Trade momentum after key level breaks\n" +
      "4. **Scalping:** Quick trades for small profits\n" +
      "5. **Position Trading:** Long-term holds based on fundamentals\n\n"
    end

    def analyze_financial_news(input, context)
      response = "**📰 FINANCIAL NEWS ANALYSIS**\n\n"
      
      response += "**Key News Categories to Monitor:**\n"
      news_categories = [
        "Earnings reports and guidance",
        "Economic indicators (GDP, inflation, employment)",
        "Central bank announcements and policy changes",
        "Geopolitical events and trade developments",
        "Industry-specific news and regulations",
        "Company-specific announcements and events"
      ]
      
      news_categories.each { |category| response += "- #{category}\n" }
      
      response += "\n**News Impact Assessment:**\n"
      impact_factors = [
        "Immediate market reaction and volatility",
        "Sector-specific implications",
        "Long-term trend changes",
        "Currency and commodity effects",
        "Options and derivatives activity",
        "Institutional investor sentiment"
      ]
      
      impact_factors.each { |factor| response += "- #{factor}\n" }
      
      response
    end

    def general_trading_advice(input, context)
      response = "**💡 GENERAL TRADING ADVICE**\n\n"
      
      response += "**Trading Fundamentals:**\n"
      fundamentals = [
        "Develop a clear trading plan and stick to it",
        "Never risk more than you can afford to lose",
        "Use proper position sizing and risk management",
        "Keep emotions in check - be disciplined",
        "Continuously educate yourself about markets",
        "Start with paper trading to practice"
      ]
      
      fundamentals.each_with_index { |fundamental, idx| response += "#{idx + 1}. #{fundamental}\n" }
      
      response += "\n**Common Trading Mistakes to Avoid:**\n"
      mistakes = [
        "Trading without a plan",
        "Revenge trading after losses",
        "Overleveraging positions",
        "Ignoring risk management",
        "Following tips without research",
        "FOMO (Fear of Missing Out) trading"
      ]
      
      mistakes.each { |mistake| response += "- #{mistake}\n" }
      
      response += "\n**⚠️ Important Disclaimer:** Trading involves substantial risk. Past performance does not guarantee future results. Always consult with qualified financial professionals."
      
      response
    end

    # Placeholder classes for advanced features
    class RiskManager
      def initialize
        # Risk management implementation
      end
    end

    class PortfolioTracker  
      def initialize
        # Portfolio tracking implementation
      end
    end

    class TechnicalIndicators
      def initialize
        # Technical indicators implementation
      end
    end
  end
end
    market_data = fetch_market_data
    localbitcoins_data = fetch_localbitcoins_data
    news_headlines = fetch_latest_news
    sentiment_score = analyze_sentiment(news_headlines)
    trading_signal = predict_trading_signal(market_data, localbitcoins_data, sentiment_score)
    visualize_data(market_data, sentiment_score)
    execute_trade(trading_signal)
    manage_risk
    log_status(market_data, localbitcoins_data, trading_signal)
    update_performance_metrics
    check_alerts
  def fetch_market_data
    @binance_client.ticker_price(symbol: @config["trading_pair"])
    log_error("Could not fetch market data: #{e.message}")
    nil
  def fetch_latest_news
    @news_client.get_top_headlines(country: "us")
    log_error("Could not fetch news: #{e.message}")
    []
  def fetch_localbitcoins_data
    @localbitcoins_client.get_ticker("BTC")
    log_error("Could not fetch Localbitcoins data: #{e.message}")
  def analyze_sentiment(news_headlines)
    headlines_text = news_headlines.map { |article| article[:title] }.join(" ")
    sentiment_score = analyze_sentiment_with_langchain(headlines_text)
    sentiment_score
  def analyze_sentiment_with_langchain(texts)
    response = Langchainrb::Model.new("gpt-4o").predict(input: { text: texts })
    sentiment_score = response.output.strip.to_f
    log_error("Sentiment analysis failed: #{e.message}")
    0.0
  def predict_trading_signal(market_data, localbitcoins_data, sentiment_score)
    combined_data = {
      market_price: market_data["price"].to_f,
      localbitcoins_price: localbitcoins_data["data"]["BTC"]["rates"]["USD"].to_f,
      sentiment_score: sentiment_score
    }
    response = Langchainrb::Model.new("gpt-4o").predict(input: { text: "Based on the following data: #{combined_data}, predict the trading signal (BUY, SELL, HOLD)." })
    response.output.strip
    log_error("Trading signal prediction failed: #{e.message}")
    "HOLD"
  def visualize_data(market_data, sentiment_score)
    # Data Sonification
    sonification = DataSonification.new(market_data)
    sonification.sonify
    # Temporal Heatmap
    heatmap = TemporalHeatmap.new(market_data)
    heatmap.generate_heatmap
    # Network Graph
    network_graph = NetworkGraph.new(market_data)
    network_graph.build_graph
    network_graph.visualize
    # Geospatial Visualization
    geospatial = GeospatialVisualization.new(market_data)
    geospatial.map_data
    # Interactive Dashboard
    dashboard = InteractiveDashboard.new(market_data: market_data, sentiment: sentiment_score)
    dashboard.create_dashboard
    dashboard.update_dashboard
  def execute_trade(trading_signal)
    case trading_signal
    when "BUY"
      @binance_client.create_order(
        symbol: @config["trading_pair"],
        side: "BUY",
        type: "MARKET",
        quantity: 0.001
      )
      log_trade("BUY")
    when "SELL"
        side: "SELL",
      log_trade("SELL")
    else
      log_trade("HOLD")
    log_error("Could not execute trade: #{e.message}")
  def manage_risk
    apply_stop_loss
    apply_take_profit
    check_risk_exposure
    log_error("Risk management failed: #{e.message}")
  def apply_stop_loss
    purchase_price = @risk_management_settings["purchase_price"]
    stop_loss_threshold = purchase_price * 0.95
    current_price = fetch_market_data["price"]
    if current_price <= stop_loss_threshold
      log_trade("STOP-LOSS")
  def apply_take_profit
    take_profit_threshold = purchase_price * 1.10
    if current_price >= take_profit_threshold
      log_trade("TAKE-PROFIT")
  def check_risk_exposure
    holdings = @binance_client.account
    # Implement logic to calculate and check risk exposure
  def log_status(market_data, localbitcoins_data, trading_signal)
    @logger.info("Market Data: #{market_data.inspect} | Localbitcoins Data: #{localbitcoins_data.inspect} | Trading Signal: #{trading_signal}")
  def update_performance_metrics
    performance_data = {
      timestamp: Time.now,
      returns: calculate_returns,
      drawdowns: calculate_drawdowns
    File.open("performance_metrics.json", "a") do |file|
      file.puts(JSON.dump(performance_data))
  def calculate_returns
    # Implement logic to calculate returns
    0 # Placeholder
  def calculate_drawdowns
    # Implement logic to calculate drawdowns
  def check_alerts
    if @alert_system.critical_alert?
      handle_alert(@alert_system.get_alert)
  def handle_error(exception)
    log_error("Error: #{exception.message}")
    @alert_system.send_alert(exception.message)
  def handle_alert(alert)
    log_error("Critical alert: #{alert}")
  def backup_data
    @backup_system.perform_backup
    log_error("Backup failed: #{e.message}")
  def log_trade(action)
    @logger.info("Trade Action: #{action} | Timestamp: #{Time.now}")
end
class TradingCLI < Thor
  desc "run", "Run the trading bot"
    trading_bot = TradingAssistant.new
    trading_bot.run
  desc "visualize", "Visualize trading data"
  def visualize
    data = fetch_data_for_visualization
    visualizer = TradingBotVisualizer.new(data)
    visualizer.run
  desc "configure", "Set up configuration"
  def configure
    puts 'Enter Binance API Key:'
    binance_api_key = STDIN.gets.chomp
    puts 'Enter Binance API Secret:'
    binance_api_secret = STDIN.gets.chomp
    puts 'Enter News API Key:'
    news_api_key = STDIN.gets.chomp
    puts 'Enter OpenAI API Key:'
    openai_api_key = STDIN.gets.chomp
    puts 'Enter Localbitcoins API Key:'
    localbitcoins_api_key = STDIN.gets.chomp
    puts 'Enter Localbitcoins API Secret:'
    localbitcoins_api_secret = STDIN.gets.chomp
    config = {
      'binance_api_key' => binance_api_key,
      'binance_api_secret' => binance_api_secret,
      'news_api_key' => news_api_key,
      'openai_api_key' => openai_api_key,
      'localbitcoins_api_key' => localbitcoins_api_key,
      'localbitcoins_api_secret' => localbitcoins_api_secret,
      'trading_pair' => 'BTCUSDT' # Default trading pair
    File.open('config.yml', 'w') { |file| file.write(config.to_yaml) }
    puts 'Configuration saved.'