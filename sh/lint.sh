#!/bin/bash

#!/usr/bin/env zsh
# Checks and fixes Ruby code files for errors.
# Usage: ./lint.sh

set -e
setopt extended_glob null_glob

check_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: $1 not found. Install it."
    exit 1
  fi
}

lint_ruby() {
  local file="$1"
  echo "Linting: $file"
  
  if ! reek "$file" >/dev/null 2>&1; then
    echo "Reek flagged: $file"
  fi
  if ! rubocop --autocorrect "$file" >/dev/null 2>&1; then
    echo "Rubocop failed: $file"
  fi
  
  echo "Done: $file"
}

check_tool "rubocop"
check_tool "reek"

find . -type f \( -name "*.rb" -o -name "*.erb" \) \
  ! -path "*/.gem/*" ! -path "*/vendor/*" | while read -r file; do
    lint_ruby "$file"
  done
