package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.*;

public class LoginSimulation extends Simulation {

    private final int normalUsers = SMOKE ? 1 : 100;
    private final int peakUsers = SMOKE ? 2 : 200;
    private final int normalSeconds = SMOKE ? 2 : 25;
    private final int peakSeconds = SMOKE ? 2 : 20;
    private final int rampSeconds = SMOKE ? 1 : 10;
    private final int peakRampSeconds = SMOKE ? 1 : 8;
    private final long pauseMillis = SMOKE ? 2000 : 750;

    private final ScenarioBuilder normalLogin =
        scenario("HU1 Login carga normal")
            .exec(
                http("Login normal")
                    .get("/login/" + USERNAME + "/" + PASSWORD)
                    .check(
                        status().is(200),
                        jsonPath("$.id").exists()
                    )
            )
            .pause(Duration.ofMillis(pauseMillis));

    private final ScenarioBuilder peakLogin =
        scenario("HU1 Login carga pico")
            .exec(
                http("Login pico")
                    .get("/login/" + USERNAME + "/" + PASSWORD)
                    .check(
                        status().is(200),
                        jsonPath("$.id").exists()
                    )
            )
            .pause(Duration.ofMillis(pauseMillis));

    {
        setUp(
            normalLogin
                .injectClosed(
                    rampConcurrentUsers(0).to(normalUsers).during(Duration.ofSeconds(rampSeconds)),
                    constantConcurrentUsers(normalUsers).during(Duration.ofSeconds(normalSeconds))
                )
                .andThen(
                    peakLogin.injectClosed(
                        rampConcurrentUsers(normalUsers).to(peakUsers).during(Duration.ofSeconds(peakRampSeconds)),
                        constantConcurrentUsers(peakUsers).during(Duration.ofSeconds(peakSeconds))
                    )
                )
        )
        .protocols(JSON)
        .assertions(
            details("Login normal").responseTime().max().lte(2000),
            details("Login normal").failedRequests().percent().is(0.0),
            details("Login pico").responseTime().max().lte(5000),
            details("Login pico").failedRequests().percent().is(0.0)
        );
    }
}
