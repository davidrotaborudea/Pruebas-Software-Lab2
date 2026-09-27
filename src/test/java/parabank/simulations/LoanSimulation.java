package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.ACCOUNT_ID;
import static parabank.config.TestConfig.CUSTOMER_ID;
import static parabank.config.TestConfig.SMOKE;

public class LoanSimulation extends Simulation {

    private final int users = SMOKE ? 1 : 150;

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
            );

    {
        setUp(
            loans.injectOpen(atOnceUsers(users))
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
