#!/usr/bin/env ruby

# VulCheck - Vulnerability Scanner
# Basic security vulnerability scanning tool

require 'socket'
require 'net/http'
require 'uri'
require 'openssl'
require 'json'

module VulCheck
  class Scanner
    attr_reader :host, :results

    def initialize(host, options = {})
      @host = host
      @options = options
      @results = { host: host, scans: {} }
    end

    def scan
      puts "Starting vulnerability scan for #{@host}"
      
      port_scan if @options[:ports] != false
      http_scan if @options[:http] != false
      ssl_scan if @options[:ssl] != false
      
      @results
    end

    private

    def port_scan
      puts "Performing port scan..."
      common_ports = [21, 22, 23, 25, 53, 80, 110, 143, 443, 993, 995]
      open_ports = []

      common_ports.each do |port|
        if port_open?(port)
          open_ports << port
          puts "  Port #{port} is open"
        end
      end

      @results[:scans][:ports] = {
        open_ports: open_ports,
        scan_time: Time.now
      }
    end

    def http_scan
      puts "Performing HTTP scan..."
      http_results = {}

      [80, 443].each do |port|
        next unless port_open?(port)
        
        scheme = port == 443 ? 'https' : 'http'
        url = "#{scheme}://#{@host}"
        
        begin
          response = get_http_response(url)
          http_results[port] = analyze_http_response(response)
        rescue => e
          http_results[port] = { error: e.message }
        end
      end

      @results[:scans][:http] = http_results
    end

    def ssl_scan
      puts "Performing SSL/TLS scan..."
      
      return unless port_open?(443)

      begin
        context = OpenSSL::SSL::SSLContext.new
        socket = TCPSocket.new(@host, 443)
        ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, context)
        ssl_socket.connect

        cert = ssl_socket.peer_cert
        ssl_info = {
          subject: cert.subject.to_s,
          issuer: cert.issuer.to_s,
          not_before: cert.not_before,
          not_after: cert.not_after,
          expired: cert.not_after < Time.now,
          version: ssl_socket.ssl_version,
          cipher: ssl_socket.cipher
        }

        ssl_socket.close
        socket.close

        @results[:scans][:ssl] = ssl_info
      rescue => e
        @results[:scans][:ssl] = { error: e.message }
      end
    end

    def port_open?(port)
      begin
        socket = TCPSocket.new(@host, port)
        socket.close
        true
      rescue
        false
      end
    end

    def get_http_response(url)
      uri = URI(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if uri.scheme == 'https'
      
      request = Net::HTTP::Get.new(uri)
      response = http.request(request)
      response
    end

    def analyze_http_response(response)
      {
        status: response.code,
        headers: response.to_hash,
        server: response['server'],
        security_headers: check_security_headers(response),
        vulnerabilities: check_http_vulnerabilities(response)
      }
    end

    def check_security_headers(response)
      security_headers = %w[
        x-frame-options
        x-content-type-options
        x-xss-protection
        strict-transport-security
        content-security-policy
      ]

      missing = security_headers.reject { |header| response[header] }
      {
        present: security_headers - missing,
        missing: missing
      }
    end

    def check_http_vulnerabilities(response)
      vulns = []

      # Check for common vulnerabilities
      vulns << 'Missing X-Frame-Options' unless response['x-frame-options']
      vulns << 'Missing X-Content-Type-Options' unless response['x-content-type-options']
      vulns << 'Server banner disclosure' if response['server']
      vulns << 'Missing HSTS header' unless response['strict-transport-security']

      vulns
    end
  end

  class Reporter
    def initialize(results)
      @results = results
    end

    def summary
      output = []
      output << "Vulnerability Scan Report for #{@results[:host]}"
      output << "=" * 50

      if @results[:scans][:ports]
        output << "\nPort Scan Results:"
        open_ports = @results[:scans][:ports][:open_ports]
        if open_ports.any?
          output << "  Open ports: #{open_ports.join(', ')}"
        else
          output << "  No open ports found"
        end
      end

      if @results[:scans][:http]
        output << "\nHTTP Scan Results:"
        @results[:scans][:http].each do |port, data|
          next if data[:error]
          
          output << "  Port #{port}:"
          output << "    Status: #{data[:status]}"
          output << "    Server: #{data[:server] || 'Unknown'}"
          
          if data[:security_headers][:missing].any?
            output << "    Missing security headers: #{data[:security_headers][:missing].join(', ')}"
          end
          
          if data[:vulnerabilities].any?
            output << "    Vulnerabilities: #{data[:vulnerabilities].join(', ')}"
          end
        end
      end

      if @results[:scans][:ssl]
        output << "\nSSL/TLS Scan Results:"
        ssl = @results[:scans][:ssl]
        
        if ssl[:error]
          output << "  Error: #{ssl[:error]}"
        else
          output << "  Certificate Subject: #{ssl[:subject]}"
          output << "  Certificate Issuer: #{ssl[:issuer]}"
          output << "  Valid Until: #{ssl[:not_after]}"
          output << "  Expired: #{ssl[:expired] ? 'Yes' : 'No'}"
          output << "  SSL Version: #{ssl[:version]}"
        end
      end

      output.join("\n")
    end

    def json_report
      @results.to_json
    end
  end
end

# Command line interface
if __FILE__ == $0
  require 'optparse'

  options = {}
  
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on('--host HOST', 'Target host to scan') do |host|
      options[:host] = host
    end
    
    opts.on('--ports PORTS', 'Comma-separated list of ports to scan') do |ports|
      options[:ports] = ports.split(',').map(&:to_i)
    end
    
    opts.on('--[no-]http', 'Enable/disable HTTP scanning') do |http|
      options[:http] = http
    end
    
    opts.on('--[no-]ssl', 'Enable/disable SSL scanning') do |ssl|
      options[:ssl] = ssl
    end
    
    opts.on('--full', 'Perform full scan (all options enabled)') do
      options[:http] = true
      options[:ssl] = true
      options[:ports] = true
    end
    
    opts.on('--report FORMAT', 'Report format (summary or json)') do |format|
      options[:report] = format
    end
    
    opts.on('-h', '--help', 'Show this help') do
      puts opts
      exit
    end
  end.parse!

  unless options[:host]
    puts "Error: --host is required"
    exit 1
  end

  scanner = VulCheck::Scanner.new(options[:host], options)
  results = scanner.scan

  reporter = VulCheck::Reporter.new(results)
  
  if options[:report] == 'json'
    puts reporter.json_report
  else
    puts reporter.summary
  end
end