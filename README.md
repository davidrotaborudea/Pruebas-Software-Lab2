# ParaBank Gatling Performance Tests

Laboratorio de rendimiento con Gatling Java DSL y dos modos de ejecución:

- ParaBank local con Docker.
- ParaBank de producción sin Docker.

GitHub Actions ejecuta siempre el perfil `full` contra producción.

## Carga full

Cada usuario ejecuta una sola operación principal. No se mantienen usuarios
concurrentes repitiendo requests durante varios segundos.

| HU | Carga full | Operaciones principales |
| --- | --- | ---: |
| HU1 Login normal | 100 usuarios a la vez | 100 logins |
| HU1 Login pico | 200 usuarios a la vez | 200 logins |
| HU2 Transferencias | 150 usuarios/s durante 1 s | 150 transferencias |
| HU3 Estados de cuenta | 200 usuarios a la vez | 200 consultas |
| HU4 Préstamos | 150 usuarios a la vez | 150 solicitudes |
| HU5 Pagos | 200 usuarios a la vez | 200 pagos |

HU2 añade una consulta de verificación por transferencia para validar que no se
pierda la operación. HU5 añade una consulta al historial por pago para comprobar
registro y ausencia de duplicados.

En producción hay una pausa de 120 segundos entre historias para evitar que el
rate limit del demo público afecte inmediatamente la siguiente HU. La pausa no
cambia la carga de cada prueba. En local con Docker no hay pausa por defecto.

La espera se puede cambiar sin modificar código:

```bash
TEST_COOLDOWN_SECONDS=60 ./scripts/run-production.sh full
```

Para desactivarla:

```bash
TEST_COOLDOWN_SECONDS=0 ./scripts/run-production.sh full
```

## Ruta del proyecto

```text
/Users/davidrodriguez/Downloads/parabank-gatling-performance/
```

## Opción 1: ejecutar ParaBank local con Docker

Requisitos:

- Docker Desktop iniciado.
- Java 21.
- Maven 3.9 o superior.
- Git, curl y Python 3.

Ejecutar full:

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
chmod +x scripts/*.sh
./scripts/run-local.sh full
```

Ejecutar smoke:

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
./scripts/run-local.sh smoke
```

La primera ejecución clona ParaBank desde:

```text
https://github.com/parasoft/parabank.git
```

y construye la imagen Docker. Las siguientes ejecuciones reutilizan la imagen.

Para reconstruir la imagen desde el repositorio público:

```bash
PARABANK_REBUILD=1 ./scripts/run-local.sh full
```

Para detener ParaBank:

```bash
./scripts/stop-parabank-local.sh
```

## Opción 2: ejecutar contra producción

No usa Docker.

Full:

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
chmod +x scripts/*.sh
./scripts/run-production.sh full
```

Smoke:

```bash
./scripts/run-production.sh smoke
```

La URL por defecto es:

```text
https://parabank.parasoft.com/parabank/services/bank
```

También puede cambiarse sin modificar código:

```bash
BASE_URL=https://otro-host/parabank/services/bank \
  ./scripts/run-production.sh full
```

## Ejecución genérica

`run-all.sh` conserva ambos perfiles:

```bash
./scripts/run-all.sh smoke
./scripts/run-all.sh full
```

Antes debe existir `target/runtime.env`, normalmente generado por:

```bash
./scripts/bootstrap-environment.sh
```

## GitHub Actions

Cada `push` a `main` ejecuta:

```bash
./scripts/run-production.sh full
```

No levanta Docker en GitHub Actions. El workflow apunta a producción, ejecuta
las cinco simulaciones con la carga `full` definida por el laboratorio y espera
120 segundos entre historias.

Si una simulación falla sus assertions, `run-all.sh` continúa con las restantes.
Al final devuelve error si una o más historias no cumplieron sus criterios.

## Reportes

Los reportes HTML de Gatling quedan en:

```text
target/gatling/
```

En GitHub Actions se publican como artifact `gatling-full-reports` incluso cuando
alguna prueba falla.
