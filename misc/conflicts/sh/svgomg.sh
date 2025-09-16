#!/usr/bin/env zsh
#
# MINIFIES SVG FILES WITH SVGO
#
#   Usage: svgomg <folder, leave empty to use current folder>
#

setopt extendedglob

dir=${1:-"."} # Default to the current directory if no argument is given

for file in $dir/**/*.svg; do
  svgo --pretty $file

  echo $file
done
