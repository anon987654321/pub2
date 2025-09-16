#!/usr/bin/env zsh
#
# OUTPUTS FILENAMES AND THEIR CONTENT TO MARKDOWN
#

setopt extendedglob

# Get the root folder name from the current directory
ROOT_FOLDER_NAME=$(basename "$PWD")

# Get the current date in YYYY-MM-DD format
CURRENT_DATE=$(date +"%Y-%m-%d")

# Define the output file name, saving it in the home directory with dynamic naming
OUTPUT_FILE="$HOME/OUTPUT_${ROOT_FOLDER_NAME}_${CURRENT_DATE}.md"

{
  # Match non-hidden files and directories in the current directory
  for path in **/*(-.N); do
    # Exclude the output file from being read
    if [[ "$path" != "$OUTPUT_FILE" ]]; then
      # Make sure it's text and not binary
      if /usr/bin/file -b "$path" | /usr/bin/grep -q "text"; then
          echo "## \`${path#./}\`"
          echo '```'
          /bin/cat "$path"
          echo '```'
          echo
      fi
    fi
  done
} > $OUTPUT_FILE
