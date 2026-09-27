package parabank.config;

public final class TestConfig {
    public static final String LOCAL_BASE_URL =
        "http://localhost:8080/parabank/services/bank";

    public static final String PUBLIC_HOST = "parabank.parasoft.com";

    public static final String BASE_URL =
        System.getProperty("baseUrl", LOCAL_BASE_URL);

    public static final String USERNAME =
        System.getProperty("username", "john");

    public static final String PASSWORD =
        System.getProperty("password", "demo");

    public static final String CUSTOMER_ID = required("customerId");

    public static final String ACCOUNT_ID = required("accountId");

    public static final String TO_ACCOUNT_ID = required("toAccountId");

    public static final String PROFILE =
        System.getProperty("profile", "smoke");

    public static final boolean SMOKE =
        "smoke".equalsIgnoreCase(PROFILE);


    private TestConfig() {
    }

    public static boolean isPublicParaBank() {
        return BASE_URL.contains(PUBLIC_HOST);
    }

    private static String required(String name) {
        String value = System.getProperty(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(
                "Missing required system property -D" + name + "=..."
            );
        }
        return value;
    }
}
