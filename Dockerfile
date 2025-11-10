# ========================
# Stage 1: Build jar
# ========================
FROM maven:eclipse-temurin AS build

WORKDIR /app

# Copy pom và source code
COPY pom.xml .
COPY src ./src

# Build jar (skip tests nếu muốn)
RUN mvn clean package -DskipTests

# ========================
# Stage 2: Run jar trên Alpine
# ========================
FROM openjdk:19-ea-jdk-alpine3.16

WORKDIR /app

# Copy jar từ stage build
COPY --from=build /app/target/*.jar app.jar

# Expose port nếu app là web
EXPOSE 8080

# Run jar
ENTRYPOINT ["java", "-jar", "app.jar"]

