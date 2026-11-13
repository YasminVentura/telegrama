FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

COPY . .

RUN mvn -pl user-profile-service -am clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/user-profile-service/target/*.jar app.jar
EXPOSE 8083
ENTRYPOINT ["java", "-jar", "app.jar"]
