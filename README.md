# ParaBank Gatling Performance Tests

Laboratorio de rendimiento con Gatling Java DSL y GitHub Actions.
El pipeline ejecuta siempre las cinco historias no funcionales con carga completa.

## Historias

| HU | Prueba | Criterio |
|---|---|---|
| 1 | Login | 100 concurrentes <= 2 s; 200 concurrentes <= 5 s |
| 2 | Transferencias | >= 150 transferencias/s, 0% fallos y feeder CSV |
| 3 | Estado de cuenta | 200 simultáneos, <= 3 s y error <= 1% |
| 4 | Préstamo | 150 concurrentes, promedio <= 5 s y éxito >= 98% |
| 5 | Pago de servicios | 200 concurrentes, <= 3 s, error <= 1% y sin duplicados |

## GitHub Actions

Configura estos secrets en el repositorio:

```text
PERF_BASE_URL
PERF_USERNAME
PERF_PASSWORD
```

`PERF_USERNAME` y `PERF_PASSWORD` son opcionales si se usa `john/demo`.

El workflow ejecuta:

```bash
./scripts/run-full.sh
```

El script obtiene el cliente y sus cuentas, genera el feeder CSV, compila las
simulaciones y ejecuta las cinco pruebas secuencialmente. Los reportes se suben
como artifact aunque una historia falle.

Un workflow rojo después de iniciar Gatling significa que una o más assertions
de rendimiento no se cumplieron. Los reportes quedan en `target/gatling/`.

## Ejecución local

Requisitos: Java 21, Maven, curl y Python 3.

```bash
export BASE_URL="https://servidor/parabank/services/bank"
export USERNAME="john"
export PASSWORD="demo"
./scripts/run-full.sh
```
