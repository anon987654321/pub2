#!/usr/bin/env zsh
#
# CHANGES PERMISSIONS AND OWNERS FOR FILES AND FOLDERS
#
#   Usage: perms <owner> <group> <file permission> <folder permission>
#

setopt nullglob globdots

owner_group="$1:$2"
file_perms="$3"
folder_perms="$4"

# Show planned changes
echo "Files: $owner_group with permissions $file_perms"
echo "Folders: $owner_group with permissions $folder_perms"

# Ask to apply the changes
read -q "choice?Apply the changes? (y/N) "
echo

if [[ "$choice" =~ ^[Yy]$ ]]
then
  chown -R "$owner_group" ./**/*
  chmod -R "$file_perms" ./**/*(.)
  chmod -R "$folder_perms" ./**/*(/)
fi
