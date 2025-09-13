#!/bin/bash

# Find and replace text across files
# Usage: ./replace.sh "old_text" "new_text" [file_pattern]

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 'old_text' 'new_text' [file_pattern]"
    echo "Example: $0 'old_name' 'new_name' '*.rb'"
    exit 1
fi

OLD_TEXT="$1"
NEW_TEXT="$2"
PATTERN="${3:-*}"

echo "Replacing '$OLD_TEXT' with '$NEW_TEXT' in files matching '$PATTERN'..."

# Find and replace in files
find . -name "$PATTERN" -type f -exec grep -l "$OLD_TEXT" {} \; | \
while read -r file; do
    echo "Processing: $file"
    sed -i.bak "s/$OLD_TEXT/$NEW_TEXT/g" "$file"
    rm -f "$file.bak"
done

echo "Replacement complete."