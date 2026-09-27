#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://localhost:8080/parabank/services/bank}"
USERNAME="${USERNAME:-john}"
PASSWORD="${PASSWORD:-demo}"
TRANSFER_FEEDER_ROWS="${TRANSFER_FEEDER_ROWS:-5000}"

mkdir -p target

echo "Preparing ParaBank test data from: ${BASE_URL}"

LOGIN_JSON="$(curl -fsS \
  --retry 5 \
  --retry-delay 2 \
  -H 'Accept: application/json' \
  "${BASE_URL}/login/${USERNAME}/${PASSWORD}")"

CUSTOMER_ID="$(python3 -c \
  'import json,sys; print(json.load(sys.stdin)["id"])' \
  <<< "${LOGIN_JSON}")"

ACCOUNTS_JSON="$(curl -fsS \
  --retry 5 \
  --retry-delay 2 \
  -H 'Accept: application/json' \
  "${BASE_URL}/customers/${CUSTOMER_ID}/accounts")"

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

cat > target/runtime.env <<EOF_ENV
BASE_URL=${BASE_URL}
USERNAME=${USERNAME}
PASSWORD=${PASSWORD}
CUSTOMER_ID=${CUSTOMER_ID}
ACCOUNT_ID=${ACCOUNT_ID}
TO_ACCOUNT_ID=${TO_ACCOUNT_ID}
EOF_ENV

python3 scripts/generate-transfer-feeder.py \
  --from-account "${ACCOUNT_ID}" \
  --to-account "${TO_ACCOUNT_ID}" \
  --rows "${TRANSFER_FEEDER_ROWS}"

echo "Runtime data prepared for customer ${CUSTOMER_ID}."
echo "Transfer feeder rows: ${TRANSFER_FEEDER_ROWS}."
