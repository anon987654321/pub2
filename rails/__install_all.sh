#!/usr/bin/env zsh
set -euo pipefail

# Install all 12 Rails apps on VPS
# Apps as defined in master.json

APPS=(
  "brgen:3000"
  "brgen_dating:3001"
  "brgen_marketplace:3002"
  "brgen_playlist:3003"
  "brgen_takeaway:3004"
  "brgen_tv:3005"
  "amber:3006"
  "baibl:3007"
  "blognet:3008"
  "bsdports:3009"
  "hjerterom:3010"
  "privcam:3011"
)

BASE_DIR="/home/dev/rails"

log() {
  print "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

for app_port in "${APPS[@]}"; do
  app="${app_port%:*}"
  port="${app_port#*:}"

  log "Deploying ${app} on port ${port}..."

  if [ -f "${BASE_DIR}/${app}.sh" ]; then
    cd "${BASE_DIR}"
    zsh "./${app}.sh" 2>&1 | tee "${app}_install.log" &
    log "${app} installation started in background (PID: $!)"
  else
    log "ERROR: ${BASE_DIR}/${app}.sh not found"
  fi
done

log "All deployments started. Check logs: ${BASE_DIR}/*_install.log"
