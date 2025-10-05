#!/usr/bin/env zsh
set -euo pipefail

commit_to_git() {
  git add -A
  git commit -m "$1"
  print "$1"
}

command_exists() {
  command -v "$1" &>/dev/null
}

check_file_exists() {
  if [[ ! -f "$1" ]]; then
    print "File $1 does not exist. Exiting..."
    exit 1
  fi
}

