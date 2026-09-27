package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.ACCOUNT_ID;
import static parabank.config.TestConfig.CUSTOMER_ID;

public class LoanSimulation extends Simulation {
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
                rampConcurrentUsers(0)
                    .to(150)
                    .during(Duration.ofSeconds(12)),
                constantConcurrentUsers(150)
                    .during(Duration.ofSeconds(20))
            )
        )
        .protocols(JSON)
        .assertions(
            details("Solicitar prestamo")
                .responseTime()
                .mean()
                .lte(5000),
            details("Solicitar prestamo")
                .successfulRequests()
                .percent()
                .gte(98.0)
        );
    }
}
