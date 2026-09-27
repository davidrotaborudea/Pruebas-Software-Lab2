# ParaBank Gatling Performance Tests

Laboratorio de rendimiento con Gatling Java DSL y ParaBank local en Docker.

## Objetivo

Las pruebas usan una instancia propia de ParaBank para evitar los `429` del servicio público.
El repositorio oficial se clona automáticamente desde:

```text
https://github.com/parasoft/parabank.git
```

ParaBank documenta su construcción con Maven y el despliegue de `target/parabank.war`
en Tomcat. Este proyecto automatiza esos pasos dentro de Docker.

## Carga full

Cada usuario ejecuta una sola operación principal. No se mantienen usuarios concurrentes
repitiendo requests durante 20 o 30 segundos.

| HU | Carga full | Requests principales |
| --- | --- | ---: |
| HU1 Login normal | 100 usuarios a la vez | 100 |
| HU1 Login pico | 200 usuarios a la vez | 200 |
| HU2 Transferencias | 160 usuarios/s durante 2 s | 320 |
| HU3 Estados de cuenta | 200 usuarios a la vez | 200 |
| HU4 Préstamos | 150 usuarios a la vez | 150 |
| HU5 Pagos | 200 usuarios a la vez | 200 |

HU2 usa 160/s para dejar margen sobre el mínimo exigido de 150 TPS y añade una
consulta de verificación por transferencia. HU5 añade una consulta al
historial por pago para validar registro y ausencia de duplicados.

## Perfiles

El código conserva ambos perfiles:

```bash
./scripts/run-local.sh smoke
./scripts/run-local.sh full
```

GitHub Actions siempre ejecuta `full`.

## Requisitos en macOS

- Docker Desktop iniciado.
- Java 21.
- Maven 3.9 o superior.
- Git, curl y Python 3.

## Ejecutar todo en tu proyecto

Tu ruta es:

```text
/Users/davidrodriguez/Downloads/parabank-gatling-performance/
```

Ejecuta:

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
chmod +x scripts/*.sh
./scripts/run-local.sh full
```

La primera ejecución clona ParaBank y construye la imagen Docker. Las siguientes
reutilizan la imagen local.

## Smoke

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
./scripts/run-local.sh smoke
```

## Full

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
./scripts/run-local.sh full
```

No existe pausa entre simulaciones.

## Levantar ParaBank solamente

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
./scripts/start-parabank-local.sh
```

Web:

```text
http://127.0.0.1:8080/parabank
```

API usada por Gatling:

```text
http://127.0.0.1:8080/parabank/services/bank
```

## Detener ParaBank

```bash
./scripts/stop-parabank-local.sh
```

## Reconstruir ParaBank desde GitHub

```bash
cd /Users/davidrodriguez/Downloads/parabank-gatling-performance
PARABANK_REBUILD=1 ./scripts/run-local.sh full
```

## Ejecutar paso por paso

```bash
./scripts/start-parabank-local.sh
./scripts/bootstrap-environment.sh
./scripts/run-all.sh full
```

Para smoke cambia la última línea por:

```bash
./scripts/run-all.sh smoke
```

## Reportes

Cada simulación genera su reporte HTML bajo:

```text
target/gatling/
```

Si una HU falla, `run-all.sh` continúa con las demás para conservar todos los reportes.
Al terminar devuelve error si alguna assertion no se cumplió.

GitHub Actions levanta ParaBank local en el runner, ejecuta siempre `full`, guarda el
log del contenedor y sube los reportes como artifact.
