package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.*;

public class StatementSimulation extends Simulation {

    private final int users = SMOKE ? 2 : 200;

    private final ScenarioBuilder statements =
        scenario("HU3 Estados de cuenta")
            .exec(
                http("Consultar estado de cuenta")
                    .get("/accounts/" + ACCOUNT_ID + "/transactions")
                    .check(
                        status().is(200),
                        jsonPath("$").ofList().exists()
                    )
            );

    {
        setUp(
            statements.injectOpen(
                atOnceUsers(users)
            )
        )
        .protocols(JSON)
        .assertions(
            details("Consultar estado de cuenta").responseTime().max().lte(3000),
            details("Consultar estado de cuenta").failedRequests().percent().lte(1.0)
        );
    }
}
