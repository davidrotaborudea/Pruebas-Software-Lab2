#!/usr/bin/env python3
import argparse
import csv
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--from-account", required=True)
    parser.add_argument("--to-account", required=True)
    parser.add_argument("--rows", type=int, default=400)
    parser.add_argument(
        "--output",
        default="src/test/resources/data/transfers.csv",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    path = Path(args.output)
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["fromAccountId", "toAccountId", "amount"])

        for index in range(args.rows):
            amount = f"{0.010000 + (index * 0.000001):.6f}"
            writer.writerow(
                [args.from_account, args.to_account, amount]
            )

    print(f"Generated {args.rows} transfer rows at {path}")


if __name__ == "__main__":
    main()
