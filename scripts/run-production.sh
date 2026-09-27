#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="${1:-full}"

export BASE_URL="${BASE_URL:-https://parabank.parasoft.com/parabank/services/bank}"
export USERNAME="${USERNAME:-john}"
export PASSWORD="${PASSWORD:-demo}"
export TRANSFER_FEEDER_ROWS="${TRANSFER_FEEDER_ROWS:-200}"

"${SCRIPT_DIR}/bootstrap-environment.sh"
"${SCRIPT_DIR}/run-all.sh" "${PROFILE}"
