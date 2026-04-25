package com.kamal.devops;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Spring Boot entry point for kamalapp.
 *
 * This is the class the Spring Boot Maven plugin detects as the main class.
 * It must be in the root package (com.kamal.devops) so component scanning
 * picks up all sub-packages (controller, config) automatically.
 *
 * The app exposes:
 *   GET /health               -> liveness + readiness probe
 *   GET /info                 -> deployment metadata
 *   GET /actuator/prometheus  -> Prometheus metrics scrape endpoint
 */
@SpringBootApplication
public class KamalAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(KamalAppApplication.class, args);
    }
}
