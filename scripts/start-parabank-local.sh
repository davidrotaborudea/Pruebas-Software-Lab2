#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

PARABANK_REPOSITORY="${PARABANK_REPOSITORY:-https://github.com/parasoft/parabank.git}"
PARABANK_REF="${PARABANK_REF:-master}"
PARABANK_SOURCE_DIR="${PARABANK_SOURCE_DIR:-${ROOT_DIR}/target/parabank-source}"
PARABANK_IMAGE="${PARABANK_IMAGE:-parabank-performance-lab:local}"
PARABANK_CONTAINER="${PARABANK_CONTAINER:-parabank-performance-lab}"
PARABANK_PORT="${PARABANK_PORT:-8080}"
PARABANK_REBUILD="${PARABANK_REBUILD:-0}"
BASE_URL="${BASE_URL:-http://127.0.0.1:${PARABANK_PORT}/parabank/services/bank}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required. Start Docker Desktop and run this script again."
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but the Docker daemon is not running."
  exit 1
fi

mkdir -p "${ROOT_DIR}/target"

if [[ "${PARABANK_REBUILD}" == "1" ]] || \
  ! docker image inspect "${PARABANK_IMAGE}" >/dev/null 2>&1; then
  if [[ ! -d "${PARABANK_SOURCE_DIR}/.git" ]]; then
    rm -rf "${PARABANK_SOURCE_DIR}"
    git clone --depth 1 "${PARABANK_REPOSITORY}" "${PARABANK_SOURCE_DIR}"
  fi

  git -C "${PARABANK_SOURCE_DIR}" fetch --depth 1 origin "${PARABANK_REF}"
  git -C "${PARABANK_SOURCE_DIR}" checkout --detach FETCH_HEAD

  echo "Building ParaBank image from ${PARABANK_REPOSITORY} (${PARABANK_REF})..."
  docker build \
    --pull \
    --tag "${PARABANK_IMAGE}" \
    --file "${ROOT_DIR}/docker/parabank.Dockerfile" \
    "${PARABANK_SOURCE_DIR}"
else
  echo "Using existing Docker image ${PARABANK_IMAGE}."
fi

docker rm -f "${PARABANK_CONTAINER}" >/dev/null 2>&1 || true

echo "Starting ParaBank at http://127.0.0.1:${PARABANK_PORT}/parabank ..."
docker run \
  --detach \
  --name "${PARABANK_CONTAINER}" \
  --publish "${PARABANK_PORT}:8080" \
  "${PARABANK_IMAGE}" >/dev/null

for ATTEMPT in $(seq 1 90); do
  if curl -fsS \
    -H 'Accept: application/json' \
    "${BASE_URL}/login/john/demo" >/dev/null 2>&1; then
    echo "ParaBank is ready: ${BASE_URL}"
    exit 0
  fi

  if ! docker ps \
    --filter "name=^/${PARABANK_CONTAINER}$" \
    --filter 'status=running' \
    --format '{{.Names}}' | grep -qx "${PARABANK_CONTAINER}"; then
    echo "ParaBank container stopped before becoming ready."
    docker logs "${PARABANK_CONTAINER}" || true
    exit 1
  fi

  sleep 2
done

echo "ParaBank did not become ready within 180 seconds."
docker logs "${PARABANK_CONTAINER}" || true
exit 1
