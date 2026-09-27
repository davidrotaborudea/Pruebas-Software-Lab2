# ParaBank + Gatling + GitHub Actions

Proyecto de pruebas de rendimiento para cinco servicios REST de ParaBank usando
Gatling Java DSL y GitHub Actions.

## Servicios cubiertos

| HU | Servicio | Endpoint | Inyección principal | Criterio automatizado |
|---|---|---|---|---|
| 1 | Login | `GET /login/{username}/{password}` | `rampConcurrentUsers` + `constantConcurrentUsers` | <= 2 s con 100 concurrentes y <= 5 s con 200 |
| 2 | Transferencia | `POST /transfer` | `constantUsersPerSec` | >= 150 req/s, 0% fallos, feeder CSV y verificación posterior |
| 3 | Estado de cuenta | `GET /accounts/{id}/transactions` | `atOnceUsers` | <= 3 s con 200 usuarios, error <= 1% |
| 4 | Préstamo | `POST /requestLoan` | `rampConcurrentUsers` + `constantConcurrentUsers` | promedio <= 5 s, éxito >= 98% con 150 concurrentes |
| 5 | Pago de servicios | `POST /billpay` | `constantConcurrentUsers` | <= 3 s, error <= 1% con 200 concurrentes + verificación en historial |

## Seguridad y entorno

No ejecutes las cargas `full` contra `https://parabank.parasoft.com` salvo que
tu profesor o el propietario del entorno haya autorizado expresamente esa carga.
El workflow incluido crea una instancia local de ParaBank dentro del runner de
GitHub Actions y ejecuta Gatling contra `localhost`.

## Requisitos locales

- Java 21
- Maven 3.6.3+
- Python 3
- `curl`
- Una instancia local/autorizada de ParaBank

La URL REST esperada por defecto es:

`http://localhost:8080/parabank/services/bank`

## Ejecución local

Con ParaBank ya iniciado:

```bash
chmod +x scripts/bootstrap-local.sh scripts/run-all.sh
./scripts/bootstrap-local.sh
./scripts/run-all.sh smoke
```

Para la carga de la entrega:

```bash
./scripts/bootstrap-local.sh
./scripts/run-all.sh full
```

Los reportes HTML quedan en:

```text
target/gatling/
```

## Ejecución individual

Después del bootstrap:

```bash
source target/runtime.env

mvn gatling:test \
  -Dgatling.simulationClass=parabank.simulations.LoginSimulation \
  -Dprofile=full \
  -DbaseUrl="$BASE_URL" \
  -Dusername="$USERNAME" \
  -Dpassword="$PASSWORD" \
  -DcustomerId="$CUSTOMER_ID" \
  -DaccountId="$ACCOUNT_ID" \
  -DtoAccountId="$TO_ACCOUNT_ID"
```

Cambia la clase por:

- `parabank.simulations.TransferSimulation`
- `parabank.simulations.StatementSimulation`
- `parabank.simulations.LoanSimulation`
- `parabank.simulations.BillPaymentSimulation`

## Feeder CSV

La historia de transferencias usa explícitamente:

```java
csv("data/transfers.csv").queue()
```

El archivo se genera durante el bootstrap con datos de las dos cuentas reales del
usuario de prueba. Cada fila contiene:

```csv
fromAccountId,toAccountId,amount
```

## GitHub Actions

El workflow `.github/workflows/performance-tests.yml`:

1. Descarga el código oficial de ParaBank.
2. Compila ParaBank.
3. Crea y arranca un contenedor local.
4. Obtiene dinámicamente el `customerId` y dos cuentas de `john/demo`.
5. Genera el feeder CSV.
6. Compila los escenarios Gatling.
7. Ejecuta las cinco simulaciones.
8. Publica los reportes HTML como artifact.

En `push` a `main` corre `smoke`.
Para la evidencia final ve a:

`Actions -> ParaBank Performance Tests -> Run workflow -> profile: full`

## Qué significa PASS/FAIL

Las assertions de Gatling convierten los criterios de aceptación en condiciones
del build. Si una de ellas no se cumple, Gatling termina con error y GitHub
Actions marca el job como fallido.

Esto es intencional: una prueba de rendimiento que no cumple el SLA debe quedar
evidenciada como fallo, no maquillarse como ejecución exitosa.

## Nota sobre pagos duplicados

Para cada usuario virtual se genera un `payeeName` único. Después de `billpay`,
el escenario consulta el historial y exige exactamente una aparición de ese
identificador. Esto permite detectar, en el alcance de ParaBank, que el mismo
pago no haya quedado registrado más de una vez para esa ejecución.

## Duración sugerida

Las cargas `full` están recortadas para que la demostración sea viable en un
runner académico. Si el profesor exige una duración concreta para cada carga,
puedes aumentar los `durationSeconds` sin cambiar la estrategia ni las
assertions.
