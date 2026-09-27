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
`full`. No usa Docker y no inicia una instancia local de ParaBank.

El runner:

1. Descarga este proyecto.
2. Configura Java 21.
3. Valida la URL del entorno de rendimiento autorizado.
4. Obtiene dinámicamente el cliente y dos cuentas del usuario de prueba.
5. Genera 5000 filas para el feeder CSV de transferencias.
6. Compila las simulaciones Gatling.
7. Ejecuta las cinco simulaciones con `profile=full`.
8. Publica los reportes Gatling como artifacts.

## Configuración de GitHub

En el repositorio abre:

`Settings > Secrets and variables > Actions > New repository secret`

Configura:

```text
PERF_BASE_URL=https://tu-entorno-autorizado/parabank/services/bank
PERF_USERNAME=john
PERF_PASSWORD=demo
```

`PERF_BASE_URL` es obligatorio. `PERF_USERNAME` y `PERF_PASSWORD` pueden
omitirse si el entorno usa `john/demo`, porque los scripts conservan esos
valores como predeterminados.

El perfil `full` se rechaza intencionalmente contra
`parabank.parasoft.com`, ya que es un host público compartido y no debe recibir
una prueba de estrés desde CI sin autorización explícita del operador.

## Requisitos locales

- Java 21
- Maven
- Python 3
- curl

Docker no es necesario.

## Ejecutar la suite completa localmente

Configura un entorno autorizado:

```bash
export BASE_URL="https://tu-entorno-autorizado/parabank/services/bank"
export USERNAME="john"
export PASSWORD="demo"
```

Prepara los datos:

```bash
chmod +x scripts/*.sh
./scripts/bootstrap-environment.sh
```

Ejecuta las cinco pruebas completas:

```bash
./scripts/run-all.sh full
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
