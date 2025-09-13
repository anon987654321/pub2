# VulCheck - Vulnerability Scanner

A simple vulnerability checking tool for basic security assessments.

## Overview

VulCheck performs basic vulnerability scans to identify common security issues:
- Open ports and services
- Outdated software versions
- Common configuration issues
- Basic web application vulnerabilities

## Features

- Port scanning
- Service fingerprinting
- HTTP header analysis
- SSL/TLS configuration checks
- Common vulnerability detection

## Usage

```ruby
require './vulcheck.rb'

# Scan a host
scanner = VulCheck::Scanner.new('example.com')
results = scanner.scan

# Generate report
report = VulCheck::Reporter.new(results)
puts report.summary
```

## Command Line Usage

```bash
# Basic scan
ruby vulcheck.rb --host example.com

# Full scan with all checks
ruby vulcheck.rb --host example.com --full

# Scan specific ports
ruby vulcheck.rb --host example.com --ports 80,443,22

# Generate detailed report
ruby vulcheck.rb --host example.com --report detailed
```

## Security Notes

- Only scan systems you own or have explicit permission to test
- This tool is for educational and authorized testing purposes only
- Some scans may be detected by intrusion detection systems
- Always follow responsible disclosure practices

## Legal Disclaimer

This tool is provided for educational and legitimate security testing purposes only. Users are responsible for ensuring they have proper authorization before scanning any systems.