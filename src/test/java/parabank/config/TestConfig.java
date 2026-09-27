package parabank.config;

public final class TestConfig {
    public static final String BASE_URL = required("baseUrl");
    public static final String USERNAME = System.getProperty("username", "john");
    public static final String PASSWORD = System.getProperty("password", "demo");
    public static final String CUSTOMER_ID = required("customerId");
    public static final String ACCOUNT_ID = required("accountId");
    public static final String TO_ACCOUNT_ID = required("toAccountId");

    private TestConfig() {
    }

    private static String required(String name) {
        String value = System.getProperty(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Missing system property -D" + name);
        }
        return value;
    }
}
