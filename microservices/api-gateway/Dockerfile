FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

# Copia o pom pai
COPY pom.xml .

# Copia o código do serviço
COPY api-gateway ./api-gateway

# Compila apenas o serviço específico
RUN mvn -pl api-gateway -am clean package -DskipTests

# Estágio 2: Rodar
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/api-gateway/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
