#!/bin/sh
set -euo pipefail
#
# CHANGES PERMISSIONS AND OWNERS FOR FILES AND FOLDERS
#
#   Usage: perms <owner> <group> <file permission> <folder permission>
#

owner_group="$1:$2"
file_perms="$3"
folder_perms="$4"

# Show planned changes
printf "Files: %s with permissions %s\n" "$owner_group" "$file_perms"
printf "Folders: %s with permissions %s\n" "$owner_group" "$folder_perms"

# Ask to apply the changes
printf "Apply the changes? (y/N) "
read -r choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
  # Safety check - ensure we have valid parameters
  if [ -z "$owner_group" ] || [ -z "$file_perms" ] || [ -z "$folder_perms" ]; then
    printf "Error: Missing required parameters\n" >&2
    exit 1
  fi

  # Use find for POSIX compatibility instead of zsh globbing
  find . -type f -exec chown "$owner_group" {} \;
  find . -type f -exec chmod "$file_perms" {} \;
  find . -type d -exec chown "$owner_group" {} \;
  find . -type d -exec chmod "$folder_perms" {} \;
fi
