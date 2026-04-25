# ─────────────────────────────────────────────
# Stage 1: Build the JAR using Maven
# ─────────────────────────────────────────────
FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /build

# Copy only the POM first to leverage Docker layer caching
# (dependencies are re-downloaded only when pom.xml changes)
COPY pom.xml .
RUN mvn dependency:go-offline --batch-mode --no-transfer-progress 2>/dev/null || true

COPY src ./src
RUN mvn clean package --batch-mode --no-transfer-progress -DskipTests

# ─────────────────────────────────────────────
# Stage 2: Runtime image — slim, non-root
# ─────────────────────────────────────────────
FROM eclipse-temurin:17-jre-jammy

# Metadata labels (good practice — visible in ECR)
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.title="kamalapp" \
      org.opencontainers.image.description="Java microservice — DevOps demo"

WORKDIR /app

# Create a non-root user for security
RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --no-create-home appuser

# Copy only the built JAR from the builder stage
COPY --from=builder /build/target/*.jar app.jar

# Set ownership
RUN chown appuser:appgroup app.jar

# Switch to non-root user
USER appuser

EXPOSE 8080

# Use exec form to ensure proper signal handling (graceful shutdown)
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
