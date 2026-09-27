#!/usr/bin/env bash
set -u

PROFILE="${1:-smoke}"

if [[ -f target/runtime.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source target/runtime.env
  set +a
fi

: "${BASE_URL:?BASE_URL is required. Run ./scripts/bootstrap-production.sh first.}"
: "${CUSTOMER_ID:?CUSTOMER_ID is required. Run ./scripts/bootstrap-production.sh first.}"
: "${ACCOUNT_ID:?ACCOUNT_ID is required. Run ./scripts/bootstrap-production.sh first.}"
: "${TO_ACCOUNT_ID:?TO_ACCOUNT_ID is required. Run ./scripts/bootstrap-production.sh first.}"

USERNAME="${USERNAME:-john}"
PASSWORD="${PASSWORD:-demo}"

PUBLIC_BASE_URL="https://parabank.parasoft.com/parabank/services/bank"

if [[ "${BASE_URL}" == "${PUBLIC_BASE_URL}"* && "${PROFILE}" != "smoke" ]]; then
  echo "Refusing a full/stress run against the public ParaBank service."
  echo "Use: ./scripts/run-all.sh smoke"
  echo "For full loads, point BASE_URL to an environment you own or are authorized to load-test."
  exit 2
fi

COMMON_ARGS=(
  "-Dprofile=${PROFILE}"
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

FAIL=0
TOTAL=${#SIMULATIONS[@]}

for i in "${!SIMULATIONS[@]}"; do
  SIM="${SIMULATIONS[$i]}"

  echo
  echo "============================================================"
  echo "Running ${SIM} with profile=${PROFILE}"
  echo "Target: ${BASE_URL}"
  echo "============================================================"

  mvn --batch-mode gatling:test \
    "-Dgatling.simulationClass=${SIM}" \
    "${COMMON_ARGS[@]}" || FAIL=1

  if [[ "${PROFILE}" == "smoke" && $((i + 1)) -lt "${TOTAL}" ]]; then
    echo
    echo "Cooling down for 20 seconds to avoid public rate limiting..."
    sleep 20
  fi
done

exit "${FAIL}"
