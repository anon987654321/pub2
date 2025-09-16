#!/bin/sh
set -euo pipefail
# Removes carriage returns, trailing whitespaces, and extra blank lines from text files.
# Usage: ./clean.sh [target_folder]

dir="${1:-.}"

if [ ! -d "$dir" ]; then
  printf "Error: '%s' is not a directory\n" "$dir" >&2
  exit 1
fi

# Use find for POSIX compatibility instead of zsh globbing
find "$dir" -type f | while read -r file; do
  if file -b "$file" | grep -q "text"; then
    tmp="$(mktemp)"
    if [ $? -ne 0 ]; then
      printf "Error: mktemp failed\n" >&2
      exit 1
    fi
    
    # Removes CRLF, trims trailing whitespaces, reduces blank lines
    if tr -d '\r' < "$file" | awk '{sub(/[ \t]+$/, "");} NF{print; if(p)print ""} {p=NF}' > "$tmp" 2>/dev/null; then
      mv "$tmp" "$file"
      printf "Cleaned: %s\n" "$file"
    else
      rm -f "$tmp"
      printf "Failed: %s\n" "$file"
    fi
  fi
done
