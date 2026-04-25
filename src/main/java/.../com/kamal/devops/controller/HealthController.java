package com.kamal.devops.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * REST controller providing /health and /info endpoints.
 *
 * /health → used by Kubernetes liveness and readiness probes (deployment.yaml)
 * /info   → used to verify which version and pod is serving traffic
 */
@RestController
public class HealthController {

    private static final String APP_NAME    = "kamalapp";
    private static final String APP_VERSION = "1.5.0";

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("status",    "UP");
        body.put("timestamp", Instant.now().toString());
        return ResponseEntity.ok(body);
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, Object>> info() {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("app",         APP_NAME);
        body.put("version",     APP_VERSION);
        body.put("description", "DevOps pipeline demo — Java 17 + Spring Boot on EKS");
        body.put("pod",         System.getenv().getOrDefault("POD_NAME", "local"));
        body.put("timestamp",   Instant.now().toString());
        return ResponseEntity.ok(body);
    }
}
