#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-https://parabank.parasoft.com/parabank/services/bank}"
USERNAME="${USERNAME:-john}"
PASSWORD="${PASSWORD:-demo}"

mkdir -p target

echo "Using ParaBank public REST API:"
echo "${BASE_URL}"
echo
echo "Reading demo customer..."

LOGIN_JSON="$(curl -fsS \
  --retry 3 \
  --retry-delay 2 \
  -H 'Accept: application/json' \
  "${BASE_URL}/login/${USERNAME}/${PASSWORD}")"

CUSTOMER_ID="$(python -c \
  'import json,sys; print(json.load(sys.stdin)["id"])' \
  <<< "${LOGIN_JSON}")"

ACCOUNTS_JSON="$(curl -fsS \
  --retry 3 \
  --retry-delay 2 \
  -H 'Accept: application/json' \
  "${BASE_URL}/customers/${CUSTOMER_ID}/accounts")"

read -r ACCOUNT_ID TO_ACCOUNT_ID < <(
  python -c '
import json,sys
accounts=json.load(sys.stdin)
if len(accounts) < 2:
    raise SystemExit("The ParaBank demo user needs at least two accounts")
print(accounts[0]["id"], accounts[1]["id"])
' <<< "${ACCOUNTS_JSON}"
)

cat > target/runtime.env <<EOF
BASE_URL=${BASE_URL}
USERNAME=${USERNAME}
PASSWORD=${PASSWORD}
CUSTOMER_ID=${CUSTOMER_ID}
ACCOUNT_ID=${ACCOUNT_ID}
TO_ACCOUNT_ID=${TO_ACCOUNT_ID}
EOF

python scripts/generate-transfer-feeder.py \
  --from-account "${ACCOUNT_ID}" \
  --to-account "${TO_ACCOUNT_ID}" \
  --rows 100

echo
echo "Production smoke-test runtime data:"
cat target/runtime.env
