#!/bin/bash

# Backup important files and directories
# Creates timestamped backups

set -e

BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "Creating backup in $BACKUP_DIR..."

# Backup key directories
cp -r ai3 "$BACKUP_DIR/" 2>/dev/null || true
cp -r rails "$BACKUP_DIR/" 2>/dev/null || true  
cp -r postpro "$BACKUP_DIR/" 2>/dev/null || true
cp -r bplans "$BACKUP_DIR/" 2>/dev/null || true

# Backup key files
cp master.json "$BACKUP_DIR/" 2>/dev/null || true
cp README.md "$BACKUP_DIR/" 2>/dev/null || true

echo "Backup created successfully in $BACKUP_DIR"