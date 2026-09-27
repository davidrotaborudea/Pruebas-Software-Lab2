# ParaBank Gatling Performance Tests

Proyecto mínimo para ejecutar las cinco historias de rendimiento contra ParaBank
producción, tanto desde GitHub Actions como desde un equipo local.

No usa Docker.

## Producción

URL por defecto:

```text
https://parabank.parasoft.com/parabank/services/bank
```

## Requisitos locales

- Java 21
- Maven
- Python 3
- curl

## Ejecutar toda la suite

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
chmod +x scripts/*.sh
./scripts/run-production.sh full all
```

En perfil `full` se esperan 300 segundos entre historias. Para quitar la espera:

```bash
TEST_COOLDOWN_SECONDS=0 ./scripts/run-production.sh full all
```

## Ejecutar una historia individual

```bash
./scripts/run-production.sh full login
./scripts/run-production.sh full transfer
./scripts/run-production.sh full statement
./scripts/run-production.sh full loan
./scripts/run-production.sh full bill
```

También se aceptan los alias `hu1`, `hu2`, `hu3`, `hu4` y `hu5`.

Al ejecutar una sola historia no hay espera adicional porque no existe una
siguiente HU.

## Smoke

Toda la suite:

```bash
./scripts/run-production.sh smoke all
```

Individual:

```bash
./scripts/run-production.sh smoke login
```

El perfil `smoke` no tiene cooldown por defecto.

## GitHub Actions

Cada push a `main` ejecuta:

```bash
./scripts/run-production.sh full all
```

GitHub Actions usa producción directamente, no Docker ni localhost.

Si una HU falla sus assertions, la ejecución continúa con las siguientes. Al
final el job queda en error si al menos una HU falló, pero los reportes de todas
las simulaciones ejecutadas se conservan.

## Reportes

```text
target/gatling/
```

En GitHub Actions se publican como artifact `gatling-full-reports`.
