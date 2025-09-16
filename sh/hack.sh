#!/bin/sh
set -euo pipefail
#
# OPENS MATCHING TEXT FILES IN VIM
#
#   Usage: hack <string, leave empty to open all files>
#

dir="${1:-.}" # Default to the current directory if no argument is given

# Use find for POSIX compatibility instead of zsh globbing
find "$dir" -type f | while read -r file; do
  # Files must be ASCII
  if file -b "$file" | grep -q "text"; then
    # Search pattern
    if [ -z "${1:-}" ] || grep -q -- "${1:-}" "$file"; then
      vim "$file"
    fi
  fi
done
