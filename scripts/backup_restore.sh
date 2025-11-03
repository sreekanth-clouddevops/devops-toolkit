#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="data"
BACKUP_DIR="backup"
BACKUP_FILE="${BACKUP_DIR}/data_backup_$(date +%F_%H-%M).tar.gz"

mkdir -p "$BACKUP_DIR"

backup() {
  echo "Creating backup..."
  tar -czf "$BACKUP_FILE" "$SRC_DIR"
  echo "Backup created: $BACKUP_FILE"
}

restore() {
  echo "Available backups:"
  ls -1 "$BACKUP_DIR"
  read -p "Enter backup filename to restore: " FILE
  [[ ! -f "$BACKUP_DIR/$FILE" ]] && { echo "File not found"; exit 1; }
  tar -xzf "$BACKUP_DIR/$FILE"
  echo "Restore complete!"
}

case "${1:-}" in
  backup) backup ;;
  restore) restore ;;
  *) echo "Usage: $0 {backup|restore}" ;;
esac
