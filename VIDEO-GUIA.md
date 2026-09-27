# Guion de video

Duración sugerida: 10 a 15 minutos.

## Objetivo

Explicar que el proyecto implementa cinco historias no funcionales con Gatling,
convierte sus criterios en assertions y ejecuta el perfil completo desde GitHub
Actions contra una instancia local de ParaBank creada dentro del runner.

## Estructura

Mostrar:

- `pom.xml`
- `src/test/java/parabank/simulations`
- `src/test/resources/data`
- `scripts`
- `.github/workflows/performance-tests.yml`
- `target/gatling` después de una ejecución

## HU1: Login

Mostrar `LoginSimulation.java` y explicar:

- 100 usuarios concurrentes en carga normal.
- 200 usuarios concurrentes en pico.
- Máximo de 2 segundos para carga normal.
- Máximo de 5 segundos para carga pico.

## HU2: Transferencias

Mostrar `TransferSimulation.java` y explicar:

- Inyección de 160 usuarios por segundo.
- Assertion mínima de 150 transferencias por segundo.
- Feeder CSV con estrategia `queue()`.
- 5000 filas generadas antes de la prueba.
- Verificación posterior de cada transferencia mediante su importe único.

## HU3: Estado de cuenta

Explicar:

- 200 usuarios lanzados simultáneamente.
- Tiempo máximo de 3 segundos.
- Error máximo del 1%.

## HU4: Préstamo

Explicar:

- 150 usuarios concurrentes.
- Tiempo promedio máximo de 5 segundos.
- Éxito mínimo del 98%.
- Validación de la estructura funcional de la respuesta.

## HU5: Pago de servicios

Explicar:

- 200 usuarios concurrentes.
- Tiempo máximo de 3 segundos.
- Error máximo del 1%.
- Identificador de beneficiario único por pago.
- Verificación en historial con una sola aparición.

## GitHub Actions

Mostrar que el workflow:

1. Configura Java 21.
2. Clona y compila ParaBank.
3. Construye e inicia ParaBank con Docker.
4. Genera los datos de prueba y el feeder.
5. Compila Gatling.
6. Ejecuta `./scripts/run-all.sh full`.
7. Publica reportes y logs como artifacts.

Aclarar que Actions no ejecuta `smoke`: el `full` se realiza contra la instancia
local creada dentro del runner.

## Cierre

Mostrar los artifacts de GitHub Actions y resumir el resultado PASS/FAIL de cada
historia. Un fallo de una assertion hace fallar el job y queda reflejado en el
reporte correspondiente.
