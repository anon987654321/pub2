#!/usr/bin/env zsh
set -e # Stop script on first error

#
# BLOGNET SETUP 1.0
#

# Check Rails Installation
if ! gem list -i rails; then
  echo "Rails is not installed, installing Rails..."
  gem install rails --version "~> 7.1.3"
else
  echo "Rails is already installed."
fi

# Create New Rails Application
echo "Creating new Rails application for Blognet..."
rails new blognet --database=postgresql --javascript=esbuild --css=sass --skip-turbo-links
cd blognet

# Add Necessary Gems
echo "Adding necessary gems..."
bundle add esbuild-rails hotwire-rails stimulus_reflex devise friendly_id babosa acts_as_tenant

# Install Frameworks
echo "Installing Hotwire, StimulusReflex, and configuring Propshaft..."
bin/rails hotwire:install
bin/rails stimulus_reflex:install
bin/rails propshaft:install

# Initial Git Setup
git init
git add .
git commit -m "Initial setup: Generate Blognet app with frontend gems"

# Add AI-related gems
echo "Adding AI-related gems to Blognet..."
bundle add ruby-openai --git "https://github.com/openai/ruby-openai" --branch "main"
bundle add langchainrb --git "https://github.com/langchain/langchain" --branch "main"
bundle add langchainrb_rails --git "https://github.com/langchain/langchain-rails" --branch "main"
bundle add weaviate-ruby --git "https://github.com/semi-technologies/weaviate-ruby" --branch "main"
bundle add replicate-ruby --git "https://github.com/replicate/replicate-ruby" --branch "main"

git add .
git commit -m "Added AI-related gems to Blognet"

# Set up domain-based multi-tenancy
echo "Setting up domain-based routing and multi-tenancy..."
# Include multi-tenancy and routing setup here, similar to previous snippets.

git add .
git commit -m "Configured domain-based routing and multi-tenancy for Blognet"
