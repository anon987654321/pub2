#!/bin/bash
set -euo pipefail

# Archives folders to dated .tgz files, skips unchanged ones.
# Usage: ./backup.sh [directory]

log_error() { echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$HOME/script_errors.log"; }

dir="${1:-.}"
checksum_file="$dir/.backup_checksums"
date_format=$(date +"%Y%m%d")
cd "$dir" || exit 1

# Load prior checksums to check for changes.
declare -A old_checksums
if [ -f "$checksum_file" ]; then
  while read -r folder checksum; do
    old_checksums["$folder"]="$checksum"
  done < "$checksum_file"
fi

declare -A new_checksums

for subdir in */; do
  [ -d "$subdir" ] || continue
  folder="${subdir%/}"

  # Creates a unique hash from all files in folder.
  checksum=$(find "$folder" -type f -exec md5sum {} + | sort | md5sum | cut -d' ' -f1)
  new_checksums["$folder"]="$checksum"

  backup_file="${folder}_${date_format}.tgz"
  if [ -z "${old_checksums[$folder]:-}" ] || [ "${old_checksums[$folder]:-}" != "$checksum" ]; then
    echo "Backing up: $folder -> $backup_file"
    if tar czf "$backup_file" "$folder" 2>/dev/null; then
      echo "Created: $backup_file"
    else
      log_error "tar failed for $backup_file"
      echo "Failed: $backup_file"
    fi
  else
    echo "Skipped (no changes): $folder"
  fi
done

# Updates checksum file for next run.
for folder in "${!new_checksums[@]}"; do
  echo "$folder ${new_checksums[$folder]}"
done > "$checksum_file"
