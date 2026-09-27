package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.PASSWORD;
import static parabank.config.TestConfig.SMOKE;
import static parabank.config.TestConfig.USERNAME;

public class LoginSimulation extends Simulation {

    private final int normalUsers = SMOKE ? 1 : 100;
    private final int peakUsers = SMOKE ? 2 : 200;

    private final ScenarioBuilder normalLogin =
        scenario("HU1 Login carga normal")
            .exec(
                http("Login normal")
                    .get("/login/" + USERNAME + "/" + PASSWORD)
                    .check(
                        status().is(200),
                        jsonPath("$.id").exists()
                    )
            );

    private final ScenarioBuilder peakLogin =
        scenario("HU1 Login carga pico")
            .exec(
                http("Login pico")
                    .get("/login/" + USERNAME + "/" + PASSWORD)
                    .check(
                        status().is(200),
                        jsonPath("$.id").exists()
                    )
            );

    {
        setUp(
            normalLogin
                .injectOpen(atOnceUsers(normalUsers))
                .andThen(peakLogin.injectOpen(atOnceUsers(peakUsers)))
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
