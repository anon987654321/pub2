#!/usr/bin/env ksh
#
# TREE-LIKE LISTING FOR FILES AND FOLDERS
#
# Usage: tree <folder, leave empty to use current folder>

print_tree() {
    local indent="$2"
    local dir="${1:-.}"
    local file

    for file in "$dir"/*; do
        if [ -d "$file" ]; then
            # Folders
            echo "${indent}+-- ${file##*/}/"
            print_tree "$file" "${indent}|   "
        else
            # Files
            [ -e "$file" ] && echo "${indent}+-- ${file##*/}"
        fi
    done
}

print_tree "$1"
