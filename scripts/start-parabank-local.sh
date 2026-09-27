#!/usr/bin/env bash
set -euo pipefail

PARABANK_REPOSITORY="${PARABANK_REPOSITORY:-https://github.com/parasoft/parabank.git}"
PARABANK_REF="${PARABANK_REF:-master}"
PARABANK_CONTAINER="${PARABANK_CONTAINER:-parabank-performance-test}"
PARABANK_IMAGE="${PARABANK_IMAGE:-parabank-performance-test:local}"
PARABANK_PORT="${PARABANK_PORT:-8080}"
PARABANK_WORK_DIR="${PARABANK_WORK_DIR:-${RUNNER_TEMP:-/tmp}/parabank-source}"
BASE_URL="${BASE_URL:-http://localhost:${PARABANK_PORT}/parabank/services/bank}"

rm -rf "${PARABANK_WORK_DIR}"
git clone --depth 1 --branch "${PARABANK_REF}" \
  "${PARABANK_REPOSITORY}" \
  "${PARABANK_WORK_DIR}"

mvn --batch-mode \
  -f "${PARABANK_WORK_DIR}/pom.xml" \
  -DskipTests \
  clean package

docker rm -f "${PARABANK_CONTAINER}" >/dev/null 2>&1 || true

docker build \
  --tag "${PARABANK_IMAGE}" \
  "${PARABANK_WORK_DIR}"

docker run \
  --detach \
  --name "${PARABANK_CONTAINER}" \
  --publish "${PARABANK_PORT}:8080" \
  "${PARABANK_IMAGE}" >/dev/null

for attempt in $(seq 1 90); do
  if curl -fsS \
    --connect-timeout 2 \
    --max-time 5 \
    "${BASE_URL}/login/john/demo" >/dev/null; then
    echo "ParaBank is ready at ${BASE_URL}"
    exit 0
  fi

  if ! docker inspect \
    --format '{{.State.Running}}' \
    "${PARABANK_CONTAINER}" 2>/dev/null | grep -q '^true$'; then
    echo "ParaBank container stopped unexpectedly."
    docker logs "${PARABANK_CONTAINER}" || true
    exit 1
  fi

  echo "Waiting for ParaBank (${attempt}/90)..."
  sleep 2
done

echo "ParaBank did not become ready in time."
docker logs "${PARABANK_CONTAINER}" || true
exit 1
