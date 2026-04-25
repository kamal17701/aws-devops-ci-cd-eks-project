# ═══════════════════════════════════════════════════════════════════════
# HOW THIS DOCKERFILE WORKS
#
# CI/CD mode (GitHub Actions / Jenkins):
#   Maven builds the JAR in Job 1 and uploads it as an artifact.
#   Job 2 downloads the JAR into target/ BEFORE running docker build.
#   Docker copies target/*.jar directly from the build context.
#   The builder stage is NOT needed — it is intentionally skipped.
#
# Local dev mode (building from scratch on your machine):
#   Run:  mvn clean package -DskipTests
#   Then: docker build .
#   The target/*.jar produced by Maven is copied into the image.
#
# Both modes produce identical final images.
# ═══════════════════════════════════════════════════════════════════════

FROM eclipse-temurin:17-jre-jammy AS runtime

# OCI standard image labels — visible in ECR and registries
ARG BUILD_DATE
ARG VCS_REF
LABEL org.opencontainers.image.title="kamalapp" \
      org.opencontainers.image.description="DevOps demo microservice — Java 17 Spring Boot" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/kamal17701/aws-devops-ci-cd-eks-project"

WORKDIR /app

# Create a non-root user — never run production containers as root.
RUN groupadd --system --gid 1001 appgroup && \
    useradd  --system --uid 1001 --gid appgroup --no-create-home appuser

# ── WHY COPY FROM target/ AND NOT FROM A BUILDER STAGE ───────────────
# The GitHub Actions pipeline builds the JAR in Job 1 (Maven runner)
# and downloads it into target/ in Job 2 (Docker runner).
# Keeping Maven out of the Docker build means:
#   • No Maven/JDK in the final image (smaller, safer)
#   • Docker build takes ~10s instead of ~3min
#   • No dependency on internet access during docker build
#
# The workflow guarantees target/*.jar exists before docker build runs.
# For local builds: run  mvn clean package -DskipTests  first.
# ─────────────────────────────────────────────────────────────────────
COPY --chown=appuser:appgroup target/*.jar app.jar

USER appuser

EXPOSE 8080

# Exec form: JVM receives SIGTERM directly → graceful shutdown works.
# UseContainerSupport: JVM respects cgroup memory limits (not host RAM).
# MaxRAMPercentage:    JVM heap uses up to 75% of the container memory limit.
ENTRYPOINT ["java", \
            "-XX:+UseContainerSupport", \
            "-XX:MaxRAMPercentage=75.0", \
            "-jar", "/app/app.jar"]
