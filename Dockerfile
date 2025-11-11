# Use a slim OpenJDK image for a typical Maven/Java app
FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# copy maven-built jar (update artifact name if necessary)
COPY target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java","-jar","/app/app.jar"]
