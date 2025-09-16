#!/bin/sh
set -euo pipefail
# Archives folders to dated .tgz files, skips unchanged ones.
# Usage: ./backup.sh [directory]

log_error() { 
  printf "[%s] %s\n" "$(date "+%Y-%m-%d %H:%M:%S")" "$1" >> "$HOME/script_errors.log"
}

dir="${1:-.}"
checksum_file="$dir/.backup_checksums"
date_format="$(date +"%Y%m%d")"
cd "$dir" || exit 1

# Temporary files to simulate associative arrays
old_checksums_tmp="$(mktemp)"
new_checksums_tmp="$(mktemp)"

# Cleanup temporary files on exit
cleanup() {
  rm -f "$old_checksums_tmp" "$new_checksums_tmp"
}
trap cleanup EXIT

# Load prior checksums to check for changes
if [ -f "$checksum_file" ]; then
  cp "$checksum_file" "$old_checksums_tmp"
fi

# Process each subdirectory
for subdir in */; do
  # Skip if no directories found
  [ -d "$subdir" ] || continue
  
  folder="${subdir%/}"
  
  # Creates a unique hash from all files in folder
  # Use portable commands instead of md5 -q
  if command -v md5sum >/dev/null 2>&1; then
    checksum="$(find "$folder" -type f -exec md5sum {} + | sort | md5sum | cut -d' ' -f1)"
  elif command -v md5 >/dev/null 2>&1; then
    checksum="$(find "$folder" -type f -exec md5 -q {} + | sort | md5 -q)"
  else
    # Fallback to sha256sum if available
    checksum="$(find "$folder" -type f -exec sha256sum {} + | sort | sha256sum | cut -d' ' -f1)"
  fi
  
  printf "%s %s\n" "$folder" "$checksum" >> "$new_checksums_tmp"

  backup_file="${folder}_${date_format}.tgz"
  
  # Check if folder has changed
  old_checksum=""
  if [ -f "$old_checksums_tmp" ]; then
    old_checksum="$(grep "^$folder " "$old_checksums_tmp" | cut -d' ' -f2 || true)"
  fi
  
  if [ -z "$old_checksum" ] || [ "$old_checksum" != "$checksum" ]; then
    printf "Backing up: %s -> %s\n" "$folder" "$backup_file"
    if tar czf "$backup_file" "$folder" 2>/dev/null; then
      printf "Created: %s\n" "$backup_file"
    else
      log_error "tar failed for $backup_file"
      printf "Failed: %s\n" "$backup_file"
    fi
  else
    printf "Skipped (no changes): %s\n" "$folder"
  fi
done

# Update checksum file for next run
mv "$new_checksums_tmp" "$checksum_file"
