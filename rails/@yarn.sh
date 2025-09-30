#!/usr/bin/env zsh
set -euo pipefail

if ! command_exists yarn; then
  print "Installing Yarn..."
  doas pkg_add -U node
  doas npm install yarn -g
fi

