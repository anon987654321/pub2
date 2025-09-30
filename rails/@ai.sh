#!/usr/bin/env zsh
set -euo pipefail

# AI integration feature setup

doas pkg_add llvm

bundle add langchainrb
bundle add langchainrb_rails
bundle add weaviate-ruby
bundle add replicate-ruby
bundle add replicate-rails

bundle install

