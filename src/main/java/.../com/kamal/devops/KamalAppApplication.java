package com.kamal.devops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Main entry point for the Spring Boot application.
 *
 * This class starts the application and enables component scanning
 * for all classes under the com.kamal.devops package, including:
 *
 * - controller
 * - config
 * - service (if added later)
 * - repository (if added later)
 *
 * Exposed endpoints:
 *   GET /health
 *   GET /info
 *   GET /actuator/health
 *   GET /actuator/prometheus
 */
@SpringBootApplication
public class KamalAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(KamalAppApplication.class, args);
    }
}
