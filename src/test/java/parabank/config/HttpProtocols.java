package parabank.config;

import io.gatling.javaapi.http.HttpProtocolBuilder;

import static io.gatling.javaapi.http.HttpDsl.http;

public final class HttpProtocols {
    public static final HttpProtocolBuilder JSON =
        http.baseUrl(TestConfig.BASE_URL)
            .acceptHeader("application/json")
            .contentTypeHeader("application/json")
            .userAgentHeader("Gatling-ParaBank-Performance-Test");

    private HttpProtocols() {
    }
}
