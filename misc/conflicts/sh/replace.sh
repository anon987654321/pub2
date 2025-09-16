#!/usr/bin/env zsh
#
# REPLACES STRINGS IN TEXT-BASED FILES OR RENAMES FILES
#
#   Usage: replace [-f] <old string> <new string> <folder, leave empty to use current folder>
#

setopt extendedglob

flag=$1

if [[ $flag == "-f" ]]; then
  is_filename_replace=true
  old_string=$2
  new_string=$3
  folder=${4:-"."} # Default to the current folder if no folder is provided
else
  is_filename_replace=false
  old_string=$1
  new_string=$2
  folder=${3:-"."} # Default to the current folder if no folder is provided
fi

echo "Replacing $old_string with $new_string in folder $folder..."

for file in $folder/**/*; do
  if [[ $is_filename_replace == true ]]; then
    # Rename part of filenames
    new_file=$(echo $file | sed "s/$old_string/$new_string/g")
    if [[ $file != $new_file ]]; then
      mv -f $file $new_file
      echo "Renamed: $file to $new_file"
    fi
  else
    # Replace strings in text files
    if file -b $file | grep -q "text" && grep -q -- "$old_string" $file; then
      sed "s/$old_string/$new_string/g" $file > $file.tmp
      mv -f $file.tmp $file
      echo "Replaced in: $file"
    fi
  fi
done
