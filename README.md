# ParaBank Gatling Performance Tests

Laboratorio de rendimiento con Gatling Java DSL y dos modos independientes:

- Local: ParaBank se levanta con Docker y las pruebas apuntan a localhost.
- Producción: no usa Docker y las pruebas apuntan al servicio público de ParaBank.

## Carga full

Cada usuario ejecuta una sola operación principal. No se mantienen usuarios
concurrentes repitiendo requests durante varios segundos.

| HU | Carga full | Requests principales |
| --- | --- | ---: |
| HU1 Login normal | 100 usuarios a la vez | 100 |
| HU1 Login pico | 200 usuarios a la vez | 200 |
| HU2 Transferencias | 150 usuarios/s durante 1 s | 150 |
| HU3 Estados de cuenta | 200 usuarios a la vez | 200 |
| HU4 Préstamos | 150 usuarios a la vez | 150 |
| HU5 Pagos | 200 usuarios a la vez | 200 |

HU2 añade una consulta de verificación por transferencia. HU5 añade una
consulta al historial por pago para validar registro y ausencia de duplicados.

## Proyecto local

Ruta usada normalmente:

```text
/Users/davidrodriguez/Downloads/parabank-gatling-performance/
```

## Ejecutar local con Docker

Con Docker Desktop iniciado:

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
chmod +x scripts/*.sh
./scripts/run-local.sh full
```

Smoke local:

```bash
./scripts/run-local.sh smoke
```

ParaBank queda disponible en:

```text
http://127.0.0.1:8080/parabank
```

Para detenerlo:

```bash
./scripts/stop-parabank-local.sh
```

Para reconstruir la imagen desde el repositorio público de ParaBank:

```bash
PARABANK_REBUILD=1 ./scripts/run-local.sh full
```

## Ejecutar contra producción

Producción no usa Docker:

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
./scripts/run-production.sh full
```

Smoke contra producción:

```bash
./scripts/run-production.sh smoke
```

La URL por defecto es:

```text
https://parabank.parasoft.com/parabank/services/bank
```

## GitHub Actions

Cada push a `main` ejecuta únicamente el flujo de producción:

```bash
./scripts/run-production.sh full
```

El workflow no construye imágenes Docker, no inicia contenedores y no usa
localhost.

## Reportes

Cada simulación genera su reporte HTML bajo:

```text
target/gatling/
```

Si una HU falla, `run-all.sh` continúa con las demás para conservar todos los
reportes. Al terminar devuelve error si alguna assertion no se cumplió.
