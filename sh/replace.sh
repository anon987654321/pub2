#!/bin/sh
set -euo pipefail
# Swaps out words in files or renames them.
# Usage: ./replace.sh [-b] <old> <new> [folder]

backup=false
if [ "$1" = "-b" ]; then
  backup=true
  shift
fi

is_filename=false
if [ "$1" = "-f" ]; then
  is_filename=true
  shift
fi

old_str="$1"
new_str="$2"
folder="${3:-.}"

if [ -z "$old_str" ] || [ -z "$new_str" ]; then
  printf "Error: Must provide old and new strings\n" >&2
  exit 1
fi
if [ ! -d "$folder" ]; then
  printf "Error: '%s' is not a directory\n" "$folder" >&2
  exit 1
fi

printf "Processing: %s\n" "$folder"

# Use find for POSIX compatibility instead of zsh globbing
find "$folder" -type f | while read -r file; do
  if $is_filename; then
    # Use parameter expansion for string replacement (POSIX compatible)
    case "$file" in
      *"$old_str"*)
        new_file="$(printf '%s' "$file" | sed "s|$old_str|$new_str|g")"
        if [ "$file" != "$new_file" ] && [ ! -e "$new_file" ]; then
          if mv "$file" "$new_file" 2>/dev/null; then
            printf "Renamed: %s -> %s\n" "$file" "$new_file"
          else
            printf "Failed: %s\n" "$file"
          fi
        fi
        ;;
    esac
  else
    if file -b "$file" | grep -q "text"; then
      if grep -q "$old_str" "$file" 2>/dev/null; then
        if $backup; then
          cp "$file" "$file.bak" 2>/dev/null || printf "Backup failed: %s\n" "$file"
        fi
        
        if sed "s|$old_str|$new_str|g" "$file" > "$file.tmp" 2>/dev/null; then
          mv "$file.tmp" "$file"
          printf "Updated: %s\n" "$file"
        else
          printf "Failed: %s\n" "$file"
          rm -f "$file.tmp"
        fi
      fi
    fi
  fi
done
