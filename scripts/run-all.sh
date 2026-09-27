#!/usr/bin/env bash
set -u

PROFILE="${1:-smoke}"

case "${PROFILE}" in
  smoke|full)
    ;;
  *)
    echo "Unsupported profile: ${PROFILE}. Use smoke or full."
    exit 2
    ;;
esac

if [[ -f target/runtime.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source target/runtime.env
  set +a
fi

: "${BASE_URL:?BASE_URL is required. Run ./scripts/bootstrap-environment.sh first.}"
: "${CUSTOMER_ID:?CUSTOMER_ID is required. Run ./scripts/bootstrap-environment.sh first.}"
: "${ACCOUNT_ID:?ACCOUNT_ID is required. Run ./scripts/bootstrap-environment.sh first.}"
: "${TO_ACCOUNT_ID:?TO_ACCOUNT_ID is required. Run ./scripts/bootstrap-environment.sh first.}"

USERNAME="${USERNAME:-john}"
PASSWORD="${PASSWORD:-demo}"
PUBLIC_HOST="parabank.parasoft.com"


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
  SIMULATION="${SIMULATIONS[$i]}"

  echo
  echo "============================================================"
  echo "Running ${SIMULATION} with profile=${PROFILE}"
  echo "Target: ${BASE_URL}"
  echo "============================================================"

  mvn --batch-mode gatling:test \
    "-Dgatling.simulationClass=${SIMULATION}" \
    "${COMMON_ARGS[@]}" || FAIL=1

  if [[ "${PROFILE}" == "smoke" && $((i + 1)) -lt "${TOTAL}" ]]; then
    echo
    echo "Cooling down for 20 seconds before the next smoke scenario..."
    sleep 20
  fi
done

exit "${FAIL}"
