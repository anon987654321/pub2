#!/usr/bin/env zsh
# encoding: utf-8

# Enable special globbing for handling files and directories
setopt extended_glob null_glob

# Define the date format for backup files
date_format=$(date +"%Y%m%d")

# Function to add backups to the list
add_backup() {
  local src=$1 prefix=$2 suffix=$3
  backups[$src]="${prefix}${suffix}_${date_format}.tgz"
}

# Initialize the backup list
declare -A backups

# Function to process a directory and its subdirectories
process_directory() {
  local dir=$1 prefix=$2
  for subdir in $dir/*(/N); do
    local name=${subdir:t}
    if [[ $name == "brgen" ]]; then
      # Add backup for 'brgen' and its subapps
      add_backup "$subdir" "$prefix" "$name"
      for subapp in $subdir/subapps/*(/N); do
        local subapp_name=${subapp:t}
        add_backup "$subapp" "${prefix}${name}_" "$subapp_name"
      done
    else
      # Add backup for other directories
      add_backup "$subdir" "$prefix" "$name"
    fi
  done
}

# Add all top-level directories (except 'rails') dynamically
for dir in */(/N); do
  if [[ ${dir:t} != "rails" ]]; then
    add_backup "$dir" "" "${dir:t}"
  fi
done

# Backup loose .sh, .rb, .txt, and .md files in the current directory
add_backup "*.(sh|rb|txt|md)(N)" "" "loose_files"

# Process the rails directory and its subdirectories
process_directory "rails" "rails_"

# Function to create backups
create_backup() {
  local src=$1 dest=$2
  if [[ $src == *\** ]]; then
    # Handle wildcard patterns
    local files=(${~src})
    if (( ${#files} )); then
      tar -czf "$dest" "${files[@]}" && echo "OK: $dest"
    else
      echo "No files matched for pattern: $src"
    fi
  else
    # Create a tarball for a regular directory or file
    mkdir -p "${dest:h}"
    tar -czf "$dest" -C "${src:h}" "${src:t}" && echo "OK: $dest"
  fi
}

# Simulate the backup process
echo
echo "Simulating backup process..."
echo
for dest in ${(on)${(v)backups}}; do echo "$dest"; done

# Ask if the user wants to proceed
echo
echo "Do you want to proceed with creating these archives? (Y/n)"
read -r response
response=${response:-Y} # Default to 'Y' if no input is given
if [[ "$response" =~ ^[Yy]$ ]]; then
  echo "Creating archives..."
  for src in ${(on)${(k)backups}}; do
    create_backup "$src" "${backups[$src]}"
  done
  echo "Backup process completed."
else
  echo "Backup process cancelled."
fi
