#!/usr/bin/env bash
set -euo pipefail

fail=0
say() { echo "[TEST] $*"; }

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_LOG="${ROOT}/data/app.log"

# 1) hello.sh should greet a provided name
out="$("${ROOT}/bin/hello.sh" Sree 2>/dev/null || true)"
echo "$out" | grep -q "Hello, Sree!" || { say "hello.sh greeting failed"; fail=1; }

# 2) disk_alert should exit 0 when threshold >= usage
"${ROOT}/bin/disk_alert.sh" -t 100 -p / >/dev/null || { say "disk_alert ok path failed"; fail=1; }

# 3) system_check should produce a log file
rm -f "${ROOT}"/logs/system_check_*.log || true
"${ROOT}/bin/system_check.sh" >/dev/null
ls "${ROOT}"/logs/system_check_*.log >/dev/null 2>&1 || { say "system_check log not created"; fail=1; }

# 4) log_analyzer should summarize a file (robust check)
TMP_OUT="$(mktemp)"
if ! "${ROOT}/scripts/log_analyzer.sh" "${APP_LOG}" 2>&1 | tee "$TMP_OUT" | grep -qi "total lines:"; then
  say "log_analyzer summary missing 'Total lines:'"
  echo "----- log_analyzer output -----"
  cat "$TMP_OUT"
  echo "--------------------------------"
  fail=1
else
  # optional: verify the error count numerically
  expected="$(grep -c 'ERROR' "${APP_LOG}")"
  actual="$(awk -F': *' '/[Ee]rror lines:/ {print $2}' "$TMP_OUT" | tr -d '\r' | tail -n1)"
  if [ -n "$actual" ] && ! [[ "$actual" =~ ^[0-9]+$ ]]; then
    say "log_analyzer error count not numeric: '$actual'"
    fail=1
  elif [ -n "$actual" ] && [ "$actual" != "$expected" ]; then
    say "log_analyzer error count mismatch: got $actual expected $expected"
    fail=1
  fi
fi
rm -f "$TMP_OUT"
