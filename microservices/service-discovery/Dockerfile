FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /app

# Copia todo o projeto (pai e filhos) para o container
COPY . .

# Compila apenas o serviço específico e suas dependências internas
RUN mvn -pl service-discovery -am clean package -DskipTests

# Estágio 2: Rodar
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/service-discovery/target/*.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]
