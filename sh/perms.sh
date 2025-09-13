#!/bin/bash

# Set correct file permissions
# Ensures scripts are executable and files have proper permissions

set -e

echo "Setting file permissions..."

# Make shell scripts executable
find . -name "*.sh" -exec chmod +x {} \;

# Set proper permissions for Ruby files
find ai3 -name "*.rb" -exec chmod 644 {} \;

# Set permissions for config files
find . -name "*.yml" -exec chmod 644 {} \;
find . -name "*.yaml" -exec chmod 644 {} \;
find . -name "*.json" -exec chmod 644 {} \;

# Set directory permissions
find . -type d -exec chmod 755 {} \;

# Set HTML/CSS/JS permissions
find . -name "*.html" -exec chmod 644 {} \;
find . -name "*.css" -exec chmod 644 {} \;
find . -name "*.js" -exec chmod 644 {} \;

echo "Permissions set correctly."