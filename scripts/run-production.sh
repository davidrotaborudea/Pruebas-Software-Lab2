#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="${1:-full}"

case "${PROFILE}" in
  smoke|full)
    ;;
  *)
    echo "Unsupported profile: ${PROFILE}. Use smoke or full."
    exit 2
    ;;
esac

export BASE_URL="${BASE_URL:-https://parabank.parasoft.com/parabank/services/bank}"
export USERNAME="${USERNAME:-john}"
export PASSWORD="${PASSWORD:-demo}"
export TRANSFER_FEEDER_ROWS="${TRANSFER_FEEDER_ROWS:-200}"
export TEST_COOLDOWN_SECONDS="${TEST_COOLDOWN_SECONDS:-120}"

"${SCRIPT_DIR}/bootstrap-environment.sh"
"${SCRIPT_DIR}/run-all.sh" "${PROFILE}"
