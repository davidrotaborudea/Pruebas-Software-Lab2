# ParaBank Gatling Performance Tests

Laboratorio de rendimiento para cinco historias no funcionales de ParaBank,
implementado con Gatling Java DSL y GitHub Actions.

## Historias cubiertas

| HU | Escenario | Criterio principal |
|---|---|---|
| 1 | Login | 100 concurrentes <= 2 s; 200 concurrentes <= 5 s |
| 2 | Transferencias | >= 150 transferencias/s, 0% fallos y feeder CSV |
| 3 | Estado de cuenta | 200 simultáneos, <= 3 s y error <= 1% |
| 4 | Préstamo | 150 concurrentes, promedio <= 5 s y éxito >= 98% |
| 5 | Pago de servicios | 200 concurrentes, <= 3 s, error <= 1% y sin duplicados |

## Estructura

El laboratorio conserva dos perfiles:

- `smoke`: ejecución rápida para comprobaciones locales.
- `full`: carga completa correspondiente a las historias no funcionales.

GitHub Actions ejecuta siempre `full`.

## Requisitos locales

- Java 21
- Maven
- Python 3
- curl

No se necesita Docker.

## Preparar datos

```bash
chmod +x scripts/bootstrap-environment.sh scripts/run-all.sh
./scripts/bootstrap-environment.sh
```

El bootstrap obtiene el cliente y dos cuentas y genera 5000 filas en
`src/test/resources/data/transfers.csv` para HU2.

## Ejecutar smoke

```bash
./scripts/run-all.sh smoke
```

## Ejecutar full

```bash
./scripts/run-all.sh full
```

## GitHub Actions

El workflow `.github/workflows/performance-tests.yml` se ejecuta en cada push a
`main` y también manualmente mediante `workflow_dispatch`.

La secuencia es:

1. Checkout.
2. Java 21.
3. Bootstrap de datos.
4. Compilación de las simulaciones.
5. Ejecución de las cinco simulaciones con `full`.
6. Publicación de los reportes de Gatling.

Los reportes quedan disponibles como artifact `gatling-full-reports`.
