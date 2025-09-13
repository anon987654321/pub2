#!/bin/bash

# Show running processes related to the project
# Useful for debugging and monitoring

set -e

echo "Showing project-related processes..."

# Ruby processes
echo "=== Ruby processes ==="
ps aux | grep ruby | grep -v grep || echo "No Ruby processes found"

# Node processes  
echo "=== Node processes ==="
ps aux | grep node | grep -v grep || echo "No Node processes found"

# Database processes
echo "=== Database processes ==="
ps aux | grep -E "(postgres|redis)" | grep -v grep || echo "No database processes found"

# Web server processes
echo "=== Web server processes ==="
ps aux | grep -E "(nginx|apache|falcon)" | grep -v grep || echo "No web server processes found"

# Memory usage
echo "=== Memory usage ==="
free -h 2>/dev/null || top -n 1 | head -5

echo "Process check complete."