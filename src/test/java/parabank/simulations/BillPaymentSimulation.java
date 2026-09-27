package parabank.simulations;

import io.gatling.javaapi.core.ScenarioBuilder;
import io.gatling.javaapi.core.Simulation;

import java.time.Duration;

import static io.gatling.javaapi.core.CoreDsl.*;
import static io.gatling.javaapi.http.HttpDsl.*;
import static parabank.config.HttpProtocols.JSON;
import static parabank.config.TestConfig.ACCOUNT_ID;
import static parabank.config.TestConfig.SMOKE;

public class BillPaymentSimulation extends Simulation {

    private final int users = SMOKE ? 1 : 200;
    private final int durationSeconds = SMOKE ? 2 : 20;
    private final long pauseMillis = SMOKE ? 2000 : 750;

    private final ScenarioBuilder billPayments =
        scenario("HU5 Pago de servicios")
            .exec(session ->
                session
                    .set(
                        "payeeName",
                        "Gatling-Service-"
                            + session.userId()
                            + "-"
                            + System.nanoTime()
                    )
                    .set("paymentAmount", "0.01")
            )
            .exec(
                http("Pagar servicio")
                    .post("/billpay")
                    .queryParam("accountId", ACCOUNT_ID)
                    .queryParam("amount", "#{paymentAmount}")
                    .body(
                        StringBody("""
                            {
                              "name": "#{payeeName}",
                              "address": {
                                "street": "1 Performance Street",
                                "city": "Medellin",
                                "state": "Antioquia",
                                "zipCode": "050001"
                              },
                              "phoneNumber": "3000000000",
                              "accountNumber": %s
                            }
                            """.formatted(ACCOUNT_ID))
                    )
                    .asJson()
                    .check(
                        status().is(200),
                        jsonPath("$.payeeName")
                            .is(session -> session.getString("payeeName")),
                        jsonPath("$.accountId")
                            .ofInt()
                            .is(Integer.parseInt(ACCOUNT_ID))
                    )
            )
            .exec(
                http("Verificar pago en historial")
                    .get("/accounts/" + ACCOUNT_ID + "/transactions")
                    .check(
                        status().is(200),
                        substring(
                            session -> session.getString("payeeName")
                        ).count().is(1)
                    )
            )
            .pause(Duration.ofMillis(pauseMillis));

    {
        setUp(
            billPayments.injectClosed(
                constantConcurrentUsers(users)
                    .during(Duration.ofSeconds(durationSeconds))
            )
        )
        .protocols(JSON)
        .assertions(
            details("Pagar servicio")
                .responseTime()
                .max()
                .lte(3000),
            details("Pagar servicio")
                .failedRequests()
                .percent()
                .lte(1.0),
            details("Verificar pago en historial")
                .failedRequests()
                .percent()
                .lte(1.0)
        );
    }
}
