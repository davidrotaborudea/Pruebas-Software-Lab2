#!/usr/bin/env bash
set -euo pipefail

PARABANK_CONTAINER="${PARABANK_CONTAINER:-parabank-performance-lab}"

docker rm -f "${PARABANK_CONTAINER}" >/dev/null 2>&1 || true
echo "ParaBank local container stopped."
