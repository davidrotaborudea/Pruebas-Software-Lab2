#!/usr/bin/env bash
set -euo pipefail

rm -rf target __MACOSX .idea .vscode
rm -rf scripts/__pycache__
rm -f src/test/resources/data/transfers.csv

find . -type f -name '.DS_Store' -delete
find . -type f -name '._*' -delete
find . -type f -name '*.pyc' -delete

echo "Generated and platform-specific files removed."
