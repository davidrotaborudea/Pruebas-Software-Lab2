#!/usr/bin/env bash
set -euo pipefail

PARABANK_CONTAINER="${PARABANK_CONTAINER:-parabank-performance-test}"
docker rm -f "${PARABANK_CONTAINER}" >/dev/null 2>&1 || true
