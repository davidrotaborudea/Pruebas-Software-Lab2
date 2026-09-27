# Guion de video — 10 a 15 minutos

Duración objetivo: aproximadamente 12 minutos.

## 0:00 - 1:00 — Objetivo

Explicar:

- Se probaron cinco servicios REST de ParaBank.
- Se usó Gatling con Java DSL.
- Se utilizaron diferentes métodos de inyección.
- La ejecución está automatizada en GitHub Actions.
- Los criterios de aceptación están codificados como assertions.

## 1:00 - 2:30 — Arquitectura del proyecto

Mostrar:

- `pom.xml`
- `src/test/java/parabank/simulations`
- `src/test/resources/data`
- `.github/workflows/performance-tests.yml`
- `target/gatling`

Mencionar que GitHub Actions levanta ParaBank localmente para no generar carga
no autorizada sobre el sitio público.

## 2:30 - 4:00 — HU1 Login

Abrir `LoginSimulation.java`.

Explicar:

- 100 usuarios concurrentes en carga normal.
- 200 usuarios concurrentes en pico.
- `rampConcurrentUsers` y `constantConcurrentUsers`.
- Assertions:
  - normal <= 2 s
  - pico <= 5 s
  - 0% de fallos

Mostrar en el reporte de Gatling los tiempos y errores.

## 4:00 - 5:30 — HU2 Transferencias

Abrir `TransferSimulation.java`.

Explicar:

- `constantUsersPerSec(160)` deja margen para verificar >= 150 req/s.
- Feeder CSV obligatorio.
- Cada usuario consume una fila de `transfers.csv`.
- Assertion >= 150 requests/segundo.
- 0% fallos.
- Se consulta cada importe único después de transferir para evidenciar que la transacción quedó registrada.

Mostrar el CSV generado y el throughput del reporte.

## 5:30 - 6:45 — HU3 Estado de cuenta

Abrir `StatementSimulation.java`.

Explicar:

- `atOnceUsers(200)` produce un pico simultáneo.
- Endpoint de transacciones.
- Máximo <= 3 s.
- Error <= 1%.

Mostrar el reporte.

## 6:45 - 8:00 — HU4 Préstamo

Abrir `LoanSimulation.java`.

Explicar:

- 150 usuarios concurrentes.
- Rampa y sostenimiento de concurrencia.
- Promedio <= 5 s.
- Éxito >= 98%.
- La prueba valida que la respuesta de negocio contenga los campos del préstamo;
  no exige que todos los préstamos sean aprobados, porque una denegación puede
  ser una respuesta funcional válida.

Mostrar el reporte.

## 8:00 - 9:15 — HU5 Pago de servicios

Abrir `BillPaymentSimulation.java`.

Explicar:

- 200 usuarios concurrentes.
- Máximo <= 3 s.
- Error <= 1%.
- Se genera un `payeeName` único.
- Luego se consulta el historial y se verifica una sola aparición del pago,
  cubriendo el criterio de no duplicación.

Mostrar las dos requests en el reporte.

## 9:15 - 11:00 — GitHub Actions

Abrir el workflow.

Mostrar:

1. Checkout.
2. Java 21.
3. Clone y build de ParaBank.
4. Docker local.
5. Bootstrap de IDs.
6. Generación del feeder.
7. Ejecución de las cinco simulaciones.
8. Upload de artifacts.

Después mostrar una ejecución `full` en Actions.

## 11:00 - 12:00 — Evidencias y cierre

Descargar o abrir el artifact de reportes.

Resumir para cada HU:

- carga usada
- método de inyección
- SLA
- PASS/FAIL observado

Cerrar indicando que un FAIL en GitHub Actions representa un criterio no cumplido,
no un error del pipeline.
