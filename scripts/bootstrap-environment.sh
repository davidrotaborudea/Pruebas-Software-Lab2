#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://parabank.parasoft.com/parabank/services/bank}"
USERNAME="${USERNAME:-john}"
PASSWORD="${PASSWORD:-demo}"
TRANSFER_FEEDER_ROWS="${TRANSFER_FEEDER_ROWS:-200}"
BOOTSTRAP_RETRIES="${BOOTSTRAP_RETRIES:-12}"
BOOTSTRAP_RETRY_DELAY_SECONDS="${BOOTSTRAP_RETRY_DELAY_SECONDS:-10}"

mkdir -p target

fetch_json() {
  local label="$1"
  local url="$2"
  local body_file
  local http_code
  local curl_status
  local attempt=1

  body_file="$(mktemp)"

  while [[ "${attempt}" -le "${BOOTSTRAP_RETRIES}" ]]; do
    curl_status=0
    http_code="$(
      curl -sS \
        -o "${body_file}" \
        -w '%{http_code}' \
        -H 'Accept: application/json' \
        "${url}"
    )" || curl_status=$?

    if [[ "${curl_status}" -eq 0 ]] && \
      [[ "${http_code}" =~ ^2[0-9][0-9]$ ]]; then
      cat "${body_file}"
      rm -f "${body_file}"
      return 0
    fi

    case "${http_code}" in
      000|429|500|502|503|504)
        if [[ "${attempt}" -lt "${BOOTSTRAP_RETRIES}" ]]; then
          echo >&2
          echo "${label} failed with HTTP ${http_code}." >&2
          echo \
            "Retry ${attempt}/${BOOTSTRAP_RETRIES} in "\
            "${BOOTSTRAP_RETRY_DELAY_SECONDS}s..." >&2
          sleep "${BOOTSTRAP_RETRY_DELAY_SECONDS}"
        fi
        ;;
      *)
        echo "${label} failed with HTTP ${http_code}." >&2
        cat "${body_file}" >&2 || true
        rm -f "${body_file}"
        return 1
        ;;
    esac

    attempt=$((attempt + 1))
  done

  echo "${label} failed after ${BOOTSTRAP_RETRIES} attempts." >&2
  cat "${body_file}" >&2 || true
  rm -f "${body_file}"
  return 1
}

write_runtime() {
  cat > target/runtime.env <<EOF_ENV
BASE_URL=${BASE_URL}
USERNAME=${USERNAME}
PASSWORD=${PASSWORD}
CUSTOMER_ID=${CUSTOMER_ID}
ACCOUNT_ID=${ACCOUNT_ID}
TO_ACCOUNT_ID=${TO_ACCOUNT_ID}
EOF_ENV
}

echo "Preparing ParaBank test data from: ${BASE_URL}"

if [[ -n "${CUSTOMER_ID:-}" ]] && \
  [[ -n "${ACCOUNT_ID:-}" ]] && \
  [[ -n "${TO_ACCOUNT_ID:-}" ]]; then
  echo "Using account IDs supplied by the environment."
else
  LOGIN_JSON="$(
    fetch_json \
      "ParaBank login bootstrap" \
      "${BASE_URL}/login/${USERNAME}/${PASSWORD}"
  )"

  CUSTOMER_ID="$(
    python3 -c \
      'import json,sys; print(json.load(sys.stdin)["id"])' \
      <<< "${LOGIN_JSON}"
  )"

  ACCOUNTS_JSON="$(
    fetch_json \
      "ParaBank accounts bootstrap" \
      "${BASE_URL}/customers/${CUSTOMER_ID}/accounts"
  )"

  read -r ACCOUNT_ID TO_ACCOUNT_ID < <(
    python3 -c '
import json
import sys

accounts = json.load(sys.stdin)
if len(accounts) < 2:
    raise SystemExit("The ParaBank test user needs at least two accounts")
print(accounts[0]["id"], accounts[1]["id"])
' <<< "${ACCOUNTS_JSON}"
  )
fi

write_runtime

python3 scripts/generate-transfer-feeder.py \
  --from-account "${ACCOUNT_ID}" \
  --to-account "${TO_ACCOUNT_ID}" \
  --rows "${TRANSFER_FEEDER_ROWS}"

echo "Runtime data prepared for customer ${CUSTOMER_ID}."
echo "Transfer feeder rows: ${TRANSFER_FEEDER_ROWS}."
