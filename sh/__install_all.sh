#!/bin/bash

# Install all required packages and dependencies
# Master script for setting up the environment

set -e

echo "Installing all dependencies..."

# OpenBSD package installation
if command -v pkg_add >/dev/null 2>&1; then
    echo "Installing OpenBSD packages..."
    pkg_add ruby git node postgresql-server redis bash
fi

# Ruby gems
if command -v bundle >/dev/null 2>&1; then
    echo "Installing Ruby gems..."
    cd ai3 && bundle install
fi

# Node packages  
if command -v npm >/dev/null 2>&1; then
    echo "Installing Node packages..."
    npm install -g yarn
fi

echo "Installation complete."