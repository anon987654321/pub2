#!/bin/bash

# Clean temporary files and build artifacts
# Removes cache, logs, and temporary files

set -e

echo "Cleaning temporary files..."

# Remove common temp files
find . -name "*.tmp" -delete 2>/dev/null || true
find . -name "*.log" -delete 2>/dev/null || true  
find . -name ".DS_Store" -delete 2>/dev/null || true
find . -name "Thumbs.db" -delete 2>/dev/null || true

# Clean Ruby artifacts
find . -name "*.gem" -delete 2>/dev/null || true
rm -rf ai3/.bundle 2>/dev/null || true

# Clean Node artifacts  
rm -rf node_modules 2>/dev/null || true
rm -rf .npm 2>/dev/null || true

# Clean backup files
find . -name "*~" -delete 2>/dev/null || true
find . -name "*.backup" -delete 2>/dev/null || true

echo "Cleanup complete."