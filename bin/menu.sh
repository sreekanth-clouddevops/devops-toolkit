#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" pwd)"ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" pwd)"
case "${1:-}" in
  check) "${ROOT}/bin/system_check.sh" ;;
  disk)  "${ROOT}/bin/disk_alert.sh" ;;
  *)
    echo "Usage: $0 {check|disk}"
    check : run system check
    disk  : run disk usage check
    exit 2
    ;;
esac
