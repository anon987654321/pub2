#!/bin/bash

#!/usr/bin/env zsh
# Finds and deletes large files to free up space.
# Usage: ./free_up_space.sh [directory]

set -e
setopt extended_glob null_glob

search_dir="${1:-.}"

if [[ ! -d "$search_dir" ]]; then
  echo "Error: '$search_dir' is not a directory"
  exit 1
fi

echo "Scanning '$search_dir'..."
typeset -a large_files
# Lists top 10 largest files by size.
find "$search_dir" -type f -exec du -k {} + 2>/dev/null | sort -nr | head -n 10 | while read -r size path; do
  human_size=$(echo "$size" | awk '{printf "%.1fK", $1}')
  large_files+=("$human_size $path")
done

if (( ${#large_files} == 0 )); then
  echo "No files found."
  exit 0
fi

echo "Largest files:"
for i in {1..${#large_files}}; do
  printf "%2d: %s\n" "$i" "${large_files[i]}"
done

echo "\nDelete? (y/N)"
read -r response
if [[ ! "$response" =~ ^[Yy]$ ]]; then
  echo "Done."
  exit 0
fi

echo "Enter numbers (e.g., 1 3 5) or 'all':"
read -r delete_list

if [[ "$delete_list" == "all" ]]; then
  for line in "${large_files[@]}"; do
    path="${line#* }"
    if rm -f "$path" 2>/dev/null; then
      echo "Deleted: $path"
    else
      echo "Failed: $path"
    fi
  done
else
  for num in ${(s: :)delete_list}; do
    if (( num >= 1 && num <= ${#large_files} )); then
      path="${large_files[num]#* }"
      if rm -f "$path" 2>/dev/null; then
        echo "Deleted: $path"
      else
        echo "Failed: $path"
      fi
    else
      echo "Invalid: $num"
    fi
  done
fi

echo "Done."
