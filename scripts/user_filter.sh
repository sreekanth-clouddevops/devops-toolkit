#!/usr/bin/env bash
set -euo pipefail

FILE="data/users.json"
jq -r '.users[] | select(.active==true) | "\(.name) - \(.role)"' "$FILE"
