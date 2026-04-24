FROM eclipse-temurin:17-jdk-jammy AS builder

WORKDIR /build

# Copy pom.xml FIRST to leverage Docker layer caching.
# Dependencies are only re-downloaded when pom.xml changes,
# not on every source code change. Cuts build time significantly.
COPY pom.xml .
RUN mvn dependency:go-offline --batch-mode --no-transfer-progress -q || true

COPY src ./src
RUN mvn clean package --batch-mode --no-transfer-progress -DskipTests

# ─────────────────────────────────────────────────────────────
# Stage 2 — Runtime image
# Uses JRE (not JDK) — smaller attack surface and image size.
# Runs as a non-root user — security best practice.
# ─────────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-jammy

# OCI standard image labels — visible in ECR and Docker Hub
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.title="kamalapp" \
      org.opencontainers.image.description="DevOps demo microservice — Java 17 Spring Boot" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/kamal17701/aws-devops-ci-cd-eks-project"

WORKDIR /app

# Create a dedicated non-root system user for running the app.
# Never run containers as root — if the container is compromised,
# the attacker only gets limited OS permissions.
RUN groupadd --system --gid 1001 appgroup && \
    useradd  --system --uid 1001 --gid appgroup --no-create-home appuser

# Copy only the built JAR from Stage 1 (not the entire build context)
COPY --from=builder --chown=appuser:appgroup /build/target/*.jar app.jar

# Switch to non-root user before EXPOSE and CMD
USER appuser

# Document the port the app listens on (informational — not a firewall rule)
EXPOSE 8080

# Use exec form (JSON array) so the JVM receives OS signals directly.
# This enables graceful shutdown — without it, SIGTERM is swallowed by a shell wrapper.
ENTRYPOINT ["java", \
            "-XX:+UseContainerSupport", \
            "-XX:MaxRAMPercentage=75.0", \
            "-jar", "/app/app.jar"]

