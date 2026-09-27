package parabank.simulations;

import io.gatling.javaapi.core.FeederBuilder;
import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;

public class TransferSimulation extends Simulation {
    private static final double TARGET_RATE = 160.0;
    private static final double MINIMUM_RATE = 150.0;

    private final FeederBuilder<String> transferFeeder =
        csv("data/transfers.csv").queue();

    private final ScenarioBuilder transfers =
        scenario("HU2 Transferencias simultaneas")
            .feed(transferFeeder)
            .exec(
                http("Transferencia")
                    .post("/transfer")
                    .queryParam("fromAccountId", "#{fromAccountId}")
                    .queryParam("toAccountId", "#{toAccountId}")
                    .queryParam("amount", "#{amount}")
                    .check(
                        status().is(200),
                        substring("Successfully transferred").exists()
                    )
            )
            .exec(
                http("Verificar transferencia")
                    .get(
                        "/accounts/#{fromAccountId}/transactions/amount/"
                            + "#{amount}"
                    )
                    .check(
                        status().is(200),
                        jsonPath("$[0].id").exists()
                    )
            );

    {
        setUp(
            transfers.injectOpen(
                constantUsersPerSec(TARGET_RATE)
                    .during(Duration.ofSeconds(20))
            )
        )
        .protocols(JSON)
        .assertions(
            details("Transferencia").requestsPerSec().gte(MINIMUM_RATE),
            details("Transferencia").failedRequests().percent().is(0.0),
            details("Verificar transferencia").failedRequests().percent().is(0.0)
        );
    }
}
