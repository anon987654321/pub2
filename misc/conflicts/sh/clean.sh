#!/usr/bin/env zsh
#
# CLEANS UP TEXT FILES
#
#   Usage: clean <target folder, leave empty to use current folder>
#

setopt extendedglob

dir=${1:-"."} # Default to the current directory if no argument is given

for file in $dir/**/*; do

  # Match text-files
  if file -b $file | grep -q "text"; then

    # Read file into a variable
    raw=$(<$file)

    # Remove CR+LF (^M)
    raw=${raw//$'\r'}

    # Remove trailing whitespace
    raw=${raw//$'[ \t]##\n'/$'\n'}

    # Compress two or more consecutive blank lines
    raw=${raw//$'\n'(#c3,)/$'\n\n'}

    # Save result and ensure two newlines at EOF
    printf "%s\n" $raw > $file

    echo $file
  fi
done
