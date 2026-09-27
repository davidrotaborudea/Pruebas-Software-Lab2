# ParaBank public endpoint mode

Target:

`https://parabank.parasoft.com/parabank/services/bank`

This mode removes the need to clone, build, initialize, or run ParaBank locally.

## Local execution

Requirements:

- Java 21
- Maven
- Python 3
- curl

Verify:

```bash
java -version
mvn -version
python3 --version
```

Prepare runtime IDs from the public demo account:

```bash
./scripts/bootstrap-production.sh
```

Run all five scenarios with the low-impact public profile:

```bash
./scripts/run-all.sh smoke
```

Reports:

```text
target/gatling/
```

On macOS:

```bash
open target/gatling/*/index.html
```

## Why there is no public `full` profile

The public ParaBank host is third-party infrastructure. The assignment-level loads
(100-200 concurrent users and 150+ transactions/second) can materially affect a
shared public service. This project therefore only permits the `smoke` profile on
the public endpoint.

The full simulations remain useful for an environment you own or have explicit
permission to load-test. Point `-DbaseUrl` / `BASE_URL` to that environment.

## Removed local-only pieces

- `scripts/bootstrap-local.sh`
- Docker/ParaBank local bootstrap logic from GitHub Actions
- Database initialization against ParaBank

The public bootstrap performs only:
- login
- account lookup
- feeder generation
