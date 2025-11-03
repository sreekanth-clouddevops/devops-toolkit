#!/usr/bin/env bash
set -euo pipefail

LOGFILE=${1:-data/app.log}
[[ ! -f "$LOGFILE" ]] && { echo "File not found: $LOGFILE"; exit 1; }

echo "===== Log Summary for: $LOGFILE ====="
echo "Total lines: $(wc -l < "$LOGFILE")"
echo "Error lines: $(grep -c 'ERROR' "$LOGFILE")"
echo "Warning lines: $(grep -c 'WARN' "$LOGFILE")"
echo "Info lines: $(grep -c 'INFO' "$LOGFILE")"
echo
echo "Top 3 recent entries:"
tail -n 3 "$LOGFILE"
