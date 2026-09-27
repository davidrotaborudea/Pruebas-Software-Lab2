# ParaBank Gatling Performance Tests

Proyecto Gatling para ejecutar las cinco historias no funcionales contra la
instancia publica de ParaBank.

No usa Docker.

## Requisitos

- Java 21
- Maven
- Python 3
- curl

## Suite completa

```bash
chmod +x scripts/*.sh
./scripts/run-production.sh full all
```

El perfil `full` espera 300 segundos entre historias cuando se ejecuta la suite
completa. Una prueba individual no tiene cooldown.

## Ejecutar una sola historia

```bash
./scripts/run-production.sh full login
./scripts/run-production.sh full transfer
./scripts/run-production.sh full statement
./scripts/run-production.sh full loan
./scripts/run-production.sh full bill
```

Tambien se aceptan `hu1`, `hu2`, `hu3`, `hu4` y `hu5`.

El login individual no necesita bootstrap de cuentas. Las otras historias
obtienen automaticamente el customer y las cuentas necesarias.

## Smoke

```bash
./scripts/run-production.sh smoke all
./scripts/run-production.sh smoke login
```

## Bootstrap y reintentos

ParaBank es un sitio demo y puede responder temporalmente con `429` o `5xx`.
El bootstrap reintenta esos errores antes de iniciar una prueba que necesite
IDs de customer/cuentas.

Valores por defecto:

```text
BOOTSTRAP_RETRIES=12
BOOTSTRAP_RETRY_DELAY_SECONDS=10
```

Se pueden cambiar sin modificar archivos:

```bash
BOOTSTRAP_RETRIES=20 \
BOOTSTRAP_RETRY_DELAY_SECONDS=15 \
./scripts/run-production.sh full transfer
```

Si el bootstrap no puede obtener los datos, el script termina antes de Gatling
en lugar de continuar con variables vacias.

Si ya conoces los IDs, puedes evitar las consultas de bootstrap:

```bash
CUSTOMER_ID=12212 \
ACCOUNT_ID=12345 \
TO_ACCOUNT_ID=12456 \
./scripts/run-production.sh full transfer
```

Usa IDs reales de la instancia actual; los valores anteriores son solo un
ejemplo de formato.

## Cooldown

Suite full sin espera:

```bash
TEST_COOLDOWN_SECONDS=0 ./scripts/run-production.sh full all
```

Suite full con dos minutos:

```bash
TEST_COOLDOWN_SECONDS=120 ./scripts/run-production.sh full all
```

## GitHub Actions

Cada push a `main` ejecuta:

```bash
./scripts/run-production.sh full all
```

contra:

```text
https://parabank.parasoft.com/parabank/services/bank
```

El workflow sube los reportes de `target/gatling/` incluso cuando alguna
assertion falla.
