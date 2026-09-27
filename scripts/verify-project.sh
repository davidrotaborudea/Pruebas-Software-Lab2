#!/usr/bin/env bash
set -euo pipefail

bash -n scripts/*.sh
python3 -m py_compile scripts/generate-transfer-feeder.py

python3 - <<'PY'
from pathlib import Path

roots = [Path("src/test/java"), Path("scripts")]
violations = []

for root in roots:
    for path in root.rglob("*"):
        if not path.is_file() or path.suffix not in {".java", ".py", ".sh"}:
            continue
        for number, line in enumerate(path.read_text().splitlines(), start=1):
            if len(line) > 100:
                violations.append(f"{path}:{number}: {len(line)} chars")

if violations:
    raise SystemExit("Lines over 100 characters:\n" + "\n".join(violations))
PY

mvn --batch-mode test-compile

echo "Project verification passed."
