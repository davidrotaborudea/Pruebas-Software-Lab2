#!/usr/bin/env bash
set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROFILE="${1:-full}"
TARGET="${2:-all}"

case "${PROFILE}" in
  smoke|full) ;;
  *)
    echo "Unsupported profile: ${PROFILE}. Use smoke or full."
    exit 2
    ;;
esac

case "${TARGET}" in
  all|login|hu1|transfer|hu2|statement|hu3|loan|hu4|bill|hu5) ;;
  *)
    echo "Unsupported test: ${TARGET}."
    echo "Use: all, login, transfer, statement, loan or bill."
    exit 2
    ;;
esac

export BASE_URL="${BASE_URL:-https://parabank.parasoft.com/parabank/services/bank}"
export USERNAME="${USERNAME:-john}"
export PASSWORD="${PASSWORD:-demo}"
export TRANSFER_FEEDER_ROWS="${TRANSFER_FEEDER_ROWS:-200}"

if [[ -z "${TEST_COOLDOWN_SECONDS+x}" ]]; then
  if [[ "${PROFILE}" == "full" ]]; then
    TEST_COOLDOWN_SECONDS=0
  else
    TEST_COOLDOWN_SECONDS=0
  fi
fi
export TEST_COOLDOWN_SECONDS

cd "${PROJECT_DIR}"

"${SCRIPT_DIR}/bootstrap-environment.sh"

set -a
# shellcheck disable=SC1091
source target/runtime.env
set +a

mvn --batch-mode test-compile

COMMON_ARGS=(
  "-Dprofile=${PROFILE}"
  "-DbaseUrl=${BASE_URL}"
  "-Dusername=${USERNAME}"
  "-Dpassword=${PASSWORD}"
  "-DcustomerId=${CUSTOMER_ID}"
  "-DaccountId=${ACCOUNT_ID}"
  "-DtoAccountId=${TO_ACCOUNT_ID}"
)

simulation_for() {
  case "$1" in
    login|hu1) echo "parabank.simulations.LoginSimulation" ;;
    transfer|hu2) echo "parabank.simulations.TransferSimulation" ;;
    statement|hu3) echo "parabank.simulations.StatementSimulation" ;;
    loan|hu4) echo "parabank.simulations.LoanSimulation" ;;
    bill|hu5) echo "parabank.simulations.BillPaymentSimulation" ;;
  esac
}

if [[ "${TARGET}" == "all" ]]; then
  TESTS=(login transfer statement loan bill)
else
  TESTS=("${TARGET}")
fi

FAIL=0
LAST_INDEX=$((${#TESTS[@]} - 1))

for INDEX in "${!TESTS[@]}"; do
  TEST_NAME="${TESTS[$INDEX]}"
  SIMULATION="$(simulation_for "${TEST_NAME}")"

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
    echo "Simulation failed. Continuing with the remaining simulations."
  fi

  if [[ "${INDEX}" -lt "${LAST_INDEX}" ]] && \
    [[ "${TEST_COOLDOWN_SECONDS}" -gt 0 ]]; then
    echo
    echo "Waiting ${TEST_COOLDOWN_SECONDS}s before the next HU..."
    sleep "${TEST_COOLDOWN_SECONDS}"
  fi
done

echo
if [[ "${FAIL}" -eq 0 ]]; then
  echo "Selected simulations completed successfully."
else
  echo "Selected simulations completed. One or more assertions failed."
fi

echo "Gatling reports: target/gatling/"
exit "${FAIL}"
