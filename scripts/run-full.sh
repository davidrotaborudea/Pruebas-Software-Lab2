#!/usr/bin/env bash
set -euo pipefail

: "${BASE_URL:?BASE_URL is required}"

USERNAME="${USERNAME:-john}"
PASSWORD="${PASSWORD:-demo}"
TRANSFER_FEEDER_ROWS=5000

LOGIN_JSON="$(curl -fsS \
  -H 'Accept: application/json' \
  "${BASE_URL}/login/${USERNAME}/${PASSWORD}")"

CUSTOMER_ID="$(python3 -c \
  'import json,sys; print(json.load(sys.stdin)["id"])' \
  <<< "${LOGIN_JSON}")"

ACCOUNTS_JSON="$(curl -fsS \
  -H 'Accept: application/json' \
  "${BASE_URL}/customers/${CUSTOMER_ID}/accounts")"

read -r ACCOUNT_ID TO_ACCOUNT_ID < <(
  python3 -c '
import json
import sys

accounts = json.load(sys.stdin)
if len(accounts) < 2:
    raise SystemExit("The test user needs at least two accounts")
print(accounts[0]["id"], accounts[1]["id"])
' <<< "${ACCOUNTS_JSON}"
)

mkdir -p src/test/resources/data

awk \
  -v rows="${TRANSFER_FEEDER_ROWS}" \
  -v from="${ACCOUNT_ID}" \
  -v to="${TO_ACCOUNT_ID}" '
BEGIN {
    print "fromAccountId,toAccountId,amount"
    for (i = 0; i < rows; i++) {
        printf "%s,%s,%.6f\n", from, to, 0.01 + (i * 0.000001)
    }
}
' > src/test/resources/data/transfers.csv

mvn --batch-mode test-compile

COMMON_ARGS=(
  "-DbaseUrl=${BASE_URL}"
  "-Dusername=${USERNAME}"
  "-Dpassword=${PASSWORD}"
  "-DcustomerId=${CUSTOMER_ID}"
  "-DaccountId=${ACCOUNT_ID}"
  "-DtoAccountId=${TO_ACCOUNT_ID}"
)

SIMULATIONS=(
  "parabank.simulations.LoginSimulation"
  "parabank.simulations.TransferSimulation"
  "parabank.simulations.StatementSimulation"
  "parabank.simulations.LoanSimulation"
  "parabank.simulations.BillPaymentSimulation"
)

set +e
FAIL=0

for SIMULATION in "${SIMULATIONS[@]}"; do
  echo
  echo "============================================================"
  echo "Running ${SIMULATION}"
  echo "============================================================"

  mvn --batch-mode gatling:test \
    "-Dgatling.simulationClass=${SIMULATION}" \
    "${COMMON_ARGS[@]}" || FAIL=1
done

exit "${FAIL}"
