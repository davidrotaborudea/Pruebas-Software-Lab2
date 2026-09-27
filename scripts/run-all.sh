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

if [[ -n "${TEST_COOLDOWN_SECONDS:-}" ]]; then
  COOLDOWN_SECONDS="${TEST_COOLDOWN_SECONDS}"
elif [[ "${PROFILE}" == "full" ]]; then
  COOLDOWN_SECONDS=90
else
  COOLDOWN_SECONDS=0
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
LAST_INDEX=$((${#SIMULATIONS[@]} - 1))

for INDEX in "${!SIMULATIONS[@]}"; do
  SIMULATION="${SIMULATIONS[$INDEX]}"

  echo
  echo "============================================================"
  echo "Running ${SIMULATION} with profile=${PROFILE}"
  echo "Target: ${BASE_URL}"
  echo "============================================================"

  if ! mvn --batch-mode gatling:test \
    "-Dgatling.simulationClass=${SIMULATION}" \
    "${COMMON_ARGS[@]}"; then
    FAIL=1
    echo
    echo "Simulation failed. The suite will continue so its report is preserved."
  fi

  if [[ "${INDEX}" -lt "${LAST_INDEX}" && "${COOLDOWN_SECONDS}" -gt 0 ]]; then
    echo
    echo "Waiting ${COOLDOWN_SECONDS}s before the next simulation..."
    sleep "${COOLDOWN_SECONDS}"
  fi
done

echo
if [[ "${FAIL}" -eq 0 ]]; then
  echo "All simulations completed successfully."
else
  echo "All simulations completed. One or more acceptance assertions failed."
fi

echo "Gatling reports are available under target/gatling/."

exit "${FAIL}"
