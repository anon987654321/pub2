#!/bin/bash

# Optimize SVG files using SVGO
# Compresses SVG files to reduce file size

set -e

if ! command -v svgo >/dev/null 2>&1; then
    echo "SVGO not found. Install with: npm install -g svgo"
    exit 1
fi

echo "Optimizing SVG files..."

# Find all SVG files and optimize them
find . -name "*.svg" -type f | while read -r file; do
    echo "Optimizing: $file"
    svgo "$file" --output "$file.optimized"
    mv "$file.optimized" "$file"
done

echo "SVG optimization complete."