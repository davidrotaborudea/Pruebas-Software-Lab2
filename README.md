# ParaBank Gatling Performance Tests

Pruebas de rendimiento para cinco historias no funcionales de ParaBank,
implementadas con Gatling Java DSL y ejecutadas en GitHub Actions.

## Historias cubiertas

| HU | Escenario | Criterio principal |
|---|---|---|
| 1 | Login | 100 concurrentes <= 2 s; 200 concurrentes <= 5 s |
| 2 | Transferencias | >= 150 transferencias/s, 0% fallos y feeder CSV |
| 3 | Estado de cuenta | 200 simultáneos, <= 3 s y error <= 1% |
| 4 | Préstamo | 150 concurrentes, promedio <= 5 s y éxito >= 98% |
| 5 | Pago de servicios | 200 concurrentes, <= 3 s, error <= 1% y sin duplicados |

## GitHub Actions

`.github/workflows/performance-tests.yml` ejecuta exclusivamente el perfil
`full`.

El runner:

1. Descarga este proyecto.
2. Configura Java 21.
3. Clona el repositorio oficial de ParaBank.
4. Compila ParaBank y construye su imagen Docker.
5. Inicia ParaBank en `localhost:8080`.
6. Obtiene dinámicamente el cliente y dos cuentas de `john/demo`.
7. Genera 5000 filas para el feeder CSV de transferencias.
8. Compila las simulaciones Gatling.
9. Ejecuta las cinco simulaciones con `profile=full`.
10. Publica los reportes Gatling y el log de ParaBank como artifacts.

Las cargas completas se ejecutan contra la instancia local del runner. El
proyecto bloquea intencionalmente `full` contra el host público compartido de
ParaBank.

## Requisitos locales

- Java 21
- Maven
- Python 3
- Git
- Docker
- curl

## Ejecutar la suite completa localmente

Primero inicia ParaBank:

```bash
chmod +x scripts/*.sh
./scripts/start-parabank-local.sh
```

Prepara los IDs y el feeder:

```bash
./scripts/bootstrap-environment.sh
```

Ejecuta las cinco pruebas completas:

```bash
./scripts/run-all.sh full
```

Al terminar:

```bash
./scripts/stop-parabank-local.sh
```

Los reportes quedan en:

```text
target/gatling/
```

## Smoke local opcional

El perfil `smoke` se conserva únicamente para comprobaciones rápidas locales:

```bash
./scripts/run-all.sh smoke
```

GitHub Actions no utiliza este perfil.

## Feeder de transferencias

HU2 utiliza explícitamente un feeder CSV:

```java
csv("data/transfers.csv").queue()
```

`bootstrap-environment.sh` genera 5000 filas por defecto. La carga `full`
inyecta 160 usuarios por segundo durante 20 segundos, por lo que necesita unas
3200 filas. Las 5000 filas dejan margen suficiente sin reutilizar datos.

Puedes cambiar la cantidad antes del bootstrap:

```bash
export TRANSFER_FEEDER_ROWS=6000
./scripts/bootstrap-environment.sh
```

## Ejecutar contra otro entorno autorizado

No necesitas iniciar Docker si ya tienes un ParaBank propio o autorizado:

```bash
export BASE_URL="https://mi-entorno/parabank/services/bank"
export USERNAME="john"
export PASSWORD="demo"
./scripts/bootstrap-environment.sh
./scripts/run-all.sh full
```

El perfil `full` se rechaza si `BASE_URL` apunta al host público compartido
`parabank.parasoft.com`.

## Validación del proyecto

Para validar scripts, longitud de líneas y compilación:

```bash
./scripts/verify-project.sh
```

Para borrar archivos generados o específicos del sistema operativo:

```bash
./scripts/clean-project.sh
```

El script conserva `.git` y el código fuente; solo elimina artefactos que pueden
regenerarse.
