FROM maven:3.9.16-eclipse-temurin-21 AS build

WORKDIR /src
COPY . .

RUN mvn -B -Dmaven.test.skip=true clean package \
    && WAR_FILE="$(find target -maxdepth 1 -type f -name '*.war' | head -n 1)" \
    && test -n "${WAR_FILE}" \
    && cp "${WAR_FILE}" /tmp/parabank.war

FROM tomcat:11.0.26-jre21-temurin-noble

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /tmp/parabank.war /usr/local/tomcat/webapps/parabank.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
