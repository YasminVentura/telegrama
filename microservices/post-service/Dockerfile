FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

COPY . .

RUN mvn -pl post-service -am clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/post-service/target/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
