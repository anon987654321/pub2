#!/bin/bash

# Run linting tools on the codebase
# Checks Ruby, JavaScript, and other code quality

set -e

echo "Running linting tools..."

# Ruby linting
if command -v rubocop >/dev/null 2>&1; then
    echo "Running RuboCop..."
    cd ai3 && rubocop . || true
    cd ..
fi

# Check shell scripts
if command -v shellcheck >/dev/null 2>&1; then
    echo "Running ShellCheck..."
    find sh -name "*.sh" -exec shellcheck {} \; || true
    find rails -name "*.sh" -exec shellcheck {} \; || true
fi

# Check JSON files
if command -v jq >/dev/null 2>&1; then
    echo "Validating JSON files..."
    find . -name "*.json" -exec jq . {} \; > /dev/null || true
fi

echo "Linting complete."