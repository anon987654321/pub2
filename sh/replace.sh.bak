#!/bin/bash

#!/usr/bin/env zsh
# Swaps out words in files or renames them.
# Usage: ./replace.sh [-b] <old> <new> [folder]

set -e
setopt extendedglob

backup=false
if [[ "$1" == "-b" ]]; then
  backup=true
  shift
fi

is_filename=false
if [[ "$1" == "-f" ]]; then
  is_filename=true
  shift
fi

old_str="$1"
new_str="$2"
folder="${3:-.}"

if [[ -z "$old_str" || -z "$new_str" ]]; then
  echo "Error: Must provide old and new strings"
  exit 1
fi
if [[ ! -d "$folder" ]]; then
  echo "Error: '$folder' is not a directory"
  exit 1
fi

echo "Processing: $folder"
for file in "$folder"/**/*(.N); do
  if "$is_filename"; then
    new_file="${file//$old_str/$new_str}"
    if [[ "$file" != "$new_file" && ! -e "$new_file" ]]; then
      mv "$file" "$new_file" 2>/dev/null
      if [[ $? -eq 0 ]]; then
        echo "Renamed: $file -> $new_file"
      else
        echo "Failed: $file"
      fi
    fi
  else
    is_text=$(file -b "$file" | grep -q "text"; echo $?)
    if [[ $is_text -eq 0 ]]; then
      if grep -q "$old_str" "$file" 2>/dev/null; then
        if "$backup"; then
          cp "$file" "$file.bak" 2>/dev/null || echo "Backup failed: $file"
        fi
        
        sed "s|$old_str|$new_str|g" "$file" > "$file.tmp" 2>/dev/null
        if [[ $? -eq 0 ]]; then
          mv "$file.tmp" "$file"
          echo "Updated: $file"
        else
          echo "Failed: $file"
          rm -f "$file.tmp"
        fi
      fi
    fi
  fi
done
