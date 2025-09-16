#!/bin/bash

#!/usr/bin/env zsh
# Creates a Markdown list of text files and their contents.
# Usage: ./showp.sh

set -e
setopt extendedglob

root=$(basename "$PWD")
date=$(date +"%Y-%m-%d_%H%M%S")
output="$HOME/OUTPUT_${root}_${date}.md"

{
  for file in **/*(-.N); do
    if [[ "$file" == "$output" ]]; then
      continue
    fi
    
    if file -b "$file" | grep -q "text"; then
      echo "## \`${file#./}\`"
      echo '```'
      cat "$file" 2>/dev/null || echo "Read failed: $file"
      echo '```'
      echo
    fi
  done
} > "$output" 2>>"$HOME/script_errors.log"
if [[ $? -ne 0 ]]; then
  echo "Failed to write $output; see $HOME/script_errors.log"
  exit 1
fi

echo "Saved: $output"
