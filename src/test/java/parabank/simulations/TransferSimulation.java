package parabank.simulations;

import io.gatling.javaapi.core.FeederBuilder;
import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.SMOKE;

public class TransferSimulation extends Simulation {

    private final double targetRate = SMOKE ? 0.5 : 160.0;
    private final double minimumRequiredRate = SMOKE ? 0.2 : 150.0;
    private final int durationSeconds = SMOKE ? 4 : 20;

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
                constantUsersPerSec(targetRate)
                    .during(Duration.ofSeconds(durationSeconds))
            )
        )
        .protocols(JSON)
        .assertions(
            details("Transferencia")
                .requestsPerSec()
                .gte(minimumRequiredRate),
            details("Transferencia")
                .failedRequests()
                .percent()
                .is(0.0),
            details("Verificar transferencia")
                .failedRequests()
                .percent()
                .is(0.0)
        );
    }
}
