# ParaBank Gatling Performance Tests

Laboratorio de pruebas de rendimiento con Gatling Java DSL sobre ParaBank.

## Perfiles

El proyecto conserva dos perfiles:

```bash
./scripts/run-all.sh smoke
./scripts/run-all.sh full
```

`smoke` usa cargas pequeñas para validar rápidamente el flujo. `full` ejecuta las cargas y
assertions definidas para las cinco historias no funcionales.

GitHub Actions siempre ejecuta:

```bash
./scripts/run-all.sh full
```

## Preparación

Antes de ejecutar las simulaciones:

```bash
chmod +x scripts/bootstrap-environment.sh scripts/run-all.sh
./scripts/bootstrap-environment.sh
```

El bootstrap obtiene los identificadores necesarios y genera el feeder CSV de transferencias.

## Ejecución local

Smoke:

```bash
./scripts/run-all.sh smoke
```

Full:

```bash
./scripts/run-all.sh full
```

## Pausa entre simulaciones

El perfil `full` espera 90 segundos entre simulaciones para evitar que una prueba deje al
servidor inmediatamente limitado para la siguiente.

La pausa se puede cambiar sin modificar código:

```bash
TEST_COOLDOWN_SECONDS=120 ./scripts/run-all.sh full
```

Para quitarla:

```bash
TEST_COOLDOWN_SECONDS=0 ./scripts/run-all.sh full
```

En `smoke` la pausa por defecto es 0 segundos.

Si una simulación falla por assertions o respuestas HTTP, `run-all.sh` continúa con las
demás para conservar todos los reportes. Al final devuelve error si alguna historia no
cumplió sus criterios.

## Reportes

Gatling genera los reportes en:

```text
target/gatling/
```

GitHub Actions los sube como artifact incluso cuando alguna simulación falla.
