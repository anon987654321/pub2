#!/usr/bin/env zsh

for file in *.sh; do 
  destination="/usr/local/bin/${file:r}"
  cp "$file" "$destination"
  chmod +x "$destination"
done
