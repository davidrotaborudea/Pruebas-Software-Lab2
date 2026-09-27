FROM maven:3.9.16-eclipse-temurin-21 AS build

WORKDIR /src
COPY . .

RUN mvn -B -Dmaven.test.skip=true clean package

FROM tomcat:11.0.26-jre21-temurin-noble

RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /src/target/parabank.war /usr/local/tomcat/webapps/parabank.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
