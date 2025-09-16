#!/bin/bash
set -euo pipefail

# Removes carriage returns, trailing whitespaces, and extra blank lines from text files.
# Usage: ./clean.sh [target_folder]

dir="${1:-.}"

if [ ! -d "$dir" ]; then
  echo "Error: '$dir' is not a directory"
  exit 1
fi

find "$dir" -type f | while read -r file; do
  if file -b "$file" | grep -q "text"; then
    tmp=$(mktemp)

    # Removes CRLF, trims trailing whitespaces, reduces blank lines.
    if tr -d '\r' < "$file" | awk '{sub(/[ \t]+$/, "");} NF{print; if(p)print ""} {p=NF}' > "$tmp" 2>/dev/null; then
      mv "$tmp" "$file"
      echo "Cleaned: $file"
    else
      rm -f "$tmp"
      echo "Failed: $file"
    fi
  fi
done
