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
FROM eclipse-temurin:25-jre-alpine-3.23

WORKDIR /app

RUN apk add --no-cache curl

# Copy jar từ stage build
COPY --from=build /app/target/*.jar app.jar

# Expose port nếu app là web
EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

USER 1001

# Run jar
ENTRYPOINT ["java", "-jar", "app.jar"]

