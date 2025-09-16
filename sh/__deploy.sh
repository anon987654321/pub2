#!/bin/sh
set -euo pipefail

for file in *.sh; do
  # Check if file exists to handle case where no .sh files exist
  [ -f "$file" ] || continue

  # Use basename to remove .sh extension (POSIX compatible)
  destination="/usr/local/bin/$(basename "$file" .sh)"
  cp "$file" "$destination"
  chmod +x "$destination"
done
