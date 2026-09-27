package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.*;

public class LoginSimulation extends Simulation {

    private final int normalUsers = SMOKE ? 10 : 100;
    private final int peakUsers = SMOKE ? 20 : 200;
    private final int normalSeconds = SMOKE ? 5 : 25;
    private final int peakSeconds = SMOKE ? 5 : 20;

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
            .pause(Duration.ofMillis(750));

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
            .pause(Duration.ofMillis(750));

    {
        setUp(
            normalLogin
                .injectClosed(
                    rampConcurrentUsers(0).to(normalUsers).during(Duration.ofSeconds(SMOKE ? 2 : 10)),
                    constantConcurrentUsers(normalUsers).during(Duration.ofSeconds(normalSeconds))
                )
                .andThen(
                    peakLogin.injectClosed(
                        rampConcurrentUsers(normalUsers).to(peakUsers).during(Duration.ofSeconds(SMOKE ? 2 : 8)),
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
