package com.kamal.devops.controller;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * Simple REST controller providing health and info endpoints.
 *
 * The primary purpose of this application is to be a deployment target
 * that demonstrates the full DevOps pipeline — not to be a complex app.
 *
 * Endpoints:
 *   GET /health  → {"status":"UP", "timestamp":"..."}
 *   GET /info    → {"app":"kamalapp", "version":"1.5", "pod":"..."}
 */
public class HealthController {

    /**
     * Health check endpoint.
     * Used by Kubernetes liveness and readiness probes.
     *
     * @return JSON map with status and timestamp
     */
    public Map<String, Object> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("timestamp", Instant.now().toString());
        return response;
    }

    /**
     * Info endpoint — returns basic app metadata.
     * Pod name is injected via the POD_NAME env variable (set in deployment.yaml).
     *
     * @return JSON map with app info
     */
    public Map<String, Object> info() {
        Map<String, Object> response = new HashMap<>();
        response.put("app", "kamalapp");
        response.put("version", "1.5");
        response.put("description", "DevOps demo microservice — Java 17 + Maven");
        response.put("pod", System.getenv().getOrDefault("POD_NAME", "unknown"));
        response.put("timestamp", Instant.now().toString());
        return response;
    }
}
