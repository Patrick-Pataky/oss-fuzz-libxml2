#!/bin/bash

set -euo pipefail

# ==== Configuration ====
SCRIPT="./build_run.sh"
DURATION_HOURS=4 # [hours]
FUZZERS=("catalog")

MESSAGE="$DURATION_HOURS hours done. Restarting..."
DURATION_SECONDS=$((DURATION_HOURS * 3600))

run() {
  local FUZZER="$1"

  echo "[${FUZZER}] Running: $SCRIPT for $DURATION_HOURS hour(s)..."
  timeout "$DURATION_SECONDS" "$SCRIPT" "$FUZZER"

  echo "[${FUZZER}] $MESSAGE"

  echo "[${FUZZER}] Running: $SCRIPT for $DURATION_HOURS hour(s)..."
  timeout "$DURATION_SECONDS" "$SCRIPT" "$FUZZER"
}

for FUZZER in "${FUZZERS[@]}"; do
  run "$FUZZER"
done

echo "All tasks completed."
