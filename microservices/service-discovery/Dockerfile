FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

COPY . .

RUN mvn -pl service-discovery -am clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/service-discovery/target/*.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]
