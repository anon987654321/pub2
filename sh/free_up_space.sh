#!/bin/bash

# Free up disk space by removing large unnecessary files
# Helps when disk space is running low

set -e

echo "Freeing up disk space..."

# Remove large cache directories
rm -rf ~/.cache 2>/dev/null || true
rm -rf /tmp/* 2>/dev/null || true

# Remove old logs
find /var/log -name "*.log.*" -delete 2>/dev/null || true

# Remove package caches (OpenBSD)
rm -rf /var/db/pkg/* 2>/dev/null || true

# Remove core dumps
find . -name "core.*" -delete 2>/dev/null || true

# Remove old backups (older than 7 days)
find . -name "backup_*" -type d -mtime +7 -exec rm -rf {} \; 2>/dev/null || true

echo "Disk space cleanup complete."