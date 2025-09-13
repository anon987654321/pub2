#!/bin/bash

# Display directory tree structure  
# Shows the project file structure in a readable format

set -e

echo "Project directory structure:"
echo "=========================="

# Use tree if available, otherwise use find
if command -v tree >/dev/null 2>&1; then
    tree -I '.git|node_modules|.bundle|*.log|*.tmp' .
else
    echo "Tree command not found, using find..."
    find . -type d \( -name .git -o -name node_modules -o -name .bundle \) -prune -o -print | \
    sed 's|[^/]*/|  |g' | \
    head -50
fi

echo ""
echo "File count by type:"
echo "=================="
echo "Ruby files: $(find . -name "*.rb" | wc -l)"
echo "HTML files: $(find . -name "*.html" | wc -l)"
echo "JavaScript files: $(find . -name "*.js" | wc -l)"
echo "Shell scripts: $(find . -name "*.sh" | wc -l)"
echo "JSON files: $(find . -name "*.json" | wc -l)"