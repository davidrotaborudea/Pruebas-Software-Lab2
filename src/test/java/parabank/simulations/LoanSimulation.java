package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.*;

public class LoanSimulation extends Simulation {

    private final int users = SMOKE ? 15 : 150;
    private final int rampSeconds = SMOKE ? 3 : 12;
    private final int holdSeconds = SMOKE ? 5 : 20;

    private final ScenarioBuilder loans =
        scenario("HU4 Solicitud de prestamo")
            .exec(
                http("Solicitar prestamo")
                    .post("/requestLoan")
                    .queryParam("customerId", CUSTOMER_ID)
                    .queryParam("amount", "100")
                    .queryParam("downPayment", "10")
                    .queryParam("fromAccountId", ACCOUNT_ID)
                    .check(
                        status().is(200),
                        jsonPath("$.approved").ofBoolean().exists(),
                        jsonPath("$.responseDate").exists(),
                        jsonPath("$.loanProviderName").exists()
                    )
            )
            .pause(Duration.ofMillis(750));

    {
        setUp(
            loans.injectClosed(
                rampConcurrentUsers(0).to(users).during(Duration.ofSeconds(rampSeconds)),
                constantConcurrentUsers(users).during(Duration.ofSeconds(holdSeconds))
            )
        )
        .protocols(JSON)
        .assertions(
            details("Solicitar prestamo").responseTime().mean().lte(5000),
            details("Solicitar prestamo").successfulRequests().percent().gte(98.0)
        );
    }
}
