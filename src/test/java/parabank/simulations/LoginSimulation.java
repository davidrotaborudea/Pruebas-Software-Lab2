package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.PASSWORD;
import static parabank.config.TestConfig.USERNAME;

public class LoginSimulation extends Simulation {
    private static final int NORMAL_USERS = 100;
    private static final int PEAK_USERS = 200;

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
                    rampConcurrentUsers(0)
                        .to(NORMAL_USERS)
                        .during(Duration.ofSeconds(10)),
                    constantConcurrentUsers(NORMAL_USERS)
                        .during(Duration.ofSeconds(25))
                )
                .andThen(
                    peakLogin.injectClosed(
                        rampConcurrentUsers(NORMAL_USERS)
                            .to(PEAK_USERS)
                            .during(Duration.ofSeconds(8)),
                        constantConcurrentUsers(PEAK_USERS)
                            .during(Duration.ofSeconds(20))
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
