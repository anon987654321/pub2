commit_to_git() {
  git add -A
  
  # Check if there are any staged changes
  if git diff --cached --quiet; then
    echo "No staged changes to commit. Skipping commit."
    return 0
  fi
  
  git commit -m "$1"
  echo "$1"
}

command_exists() {
  command -v "$1" &>/dev/null
}

check_file_exists() {
  if [ ! -f "$1" ]; then
    echo "File $1 does not exist. Exiting..."
    exit 1
  fi
}

