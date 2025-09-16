#!/bin/sh
set -euo pipefail
# Finds and deletes large files to free up space.
# Usage: ./free_up_space.sh [directory]

search_dir="${1:-.}"

if [ ! -d "$search_dir" ]; then
  printf "Error: '%s' is not a directory\n" "$search_dir" >&2
  exit 1
fi

printf "Scanning '%s'...\n" "$search_dir"

# Create temporary file for large files list
large_files_tmp="$(mktemp)"
cleanup() {
  rm -f "$large_files_tmp"
}
trap cleanup EXIT

# Lists top 10 largest files by size
find "$search_dir" -type f -exec du -k {} + 2>/dev/null | sort -nr | head -n 10 > "$large_files_tmp"

if [ ! -s "$large_files_tmp" ]; then
  printf "No files found.\n"
  exit 0
fi

printf "Largest files:\n"
i=1
while read -r size path; do
  human_size="$(awk "BEGIN {printf \"%.1fK\", $size}")"
  printf "%2d: %s %s\n" "$i" "$human_size" "$path"
  i=$((i + 1))
done < "$large_files_tmp"

printf "\nDelete? (y/N) "
read -r response
case "$response" in
  [Yy]|[Yy][Ee][Ss]) ;;
  *) printf "Done.\n"; exit 0 ;;
esac

printf "Enter numbers (e.g., 1 3 5) or 'all': "
read -r delete_list

if [ "$delete_list" = "all" ]; then
  while read -r size path; do
    if [ -n "$path" ] && rm -f "$path" 2>/dev/null; then
      printf "Deleted: %s\n" "$path"
    else
      printf "Failed: %s\n" "$path"
    fi
  done < "$large_files_tmp"
else
  for num in $delete_list; do
    # Get the nth line from the file
    line="$(sed -n "${num}p" "$large_files_tmp")"
    if [ -n "$line" ]; then
      path="$(printf '%s' "$line" | cut -d' ' -f2-)"
      if [ -n "$path" ] && rm -f "$path" 2>/dev/null; then
        printf "Deleted: %s\n" "$path"
      else
        printf "Failed: %s\n" "$path"
      fi
    else
      printf "Invalid: %s\n" "$num"
    fi
  done
fi

printf "Done.\n"
