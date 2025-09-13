# PounceKeys - Keystroke Analysis Tool

A simple tool for analyzing keystroke patterns and timing.

## Overview

PounceKeys analyzes typing patterns to provide insights into:
- Typing speed and rhythm
- Common key combinations
- Timing patterns
- Potential ergonomic issues

## Features

- Real-time keystroke monitoring
- Statistical analysis of typing patterns
- Export data for further analysis
- Privacy-focused (local processing only)

## Usage

```ruby
require './pouncekeys.rb'

# Start monitoring
monitor = PounceKeys::Monitor.new
monitor.start

# Analyze patterns
analyzer = PounceKeys::Analyzer.new(monitor.data)
stats = analyzer.generate_stats

puts stats.summary
```

## Privacy

- All data is processed locally
- No data is transmitted over the network
- User has full control over data retention

## Requirements

- Ruby 3.0+
- Platform-specific keystroke monitoring libraries

## Installation

1. Install required gems
2. Run the application
3. Grant necessary permissions for keystroke monitoring

## Legal Notice

This tool is for educational and ergonomic analysis purposes only. Ensure you have proper authorization before monitoring any keystrokes.