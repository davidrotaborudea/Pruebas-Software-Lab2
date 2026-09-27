#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("--from-account", required=True)
parser.add_argument("--to-account", required=True)
parser.add_argument("--rows", type=int, default=5000)
parser.add_argument(
    "--output",
    default="src/test/resources/data/transfers.csv"
)
args = parser.parse_args()

path = Path(args.output)
path.parent.mkdir(parents=True, exist_ok=True)

with path.open("w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["fromAccountId", "toAccountId", "amount"])
    for i in range(args.rows):
        # Importes pequeños y únicos: permiten distinguir operaciones y evitan
        # consumir rápidamente el saldo de la cuenta de prueba.
        amount = f"{0.010000 + (i * 0.000001):.6f}"
        writer.writerow([args.from_account, args.to_account, amount])

print(f"Generated {args.rows} transfer rows at {path}")
