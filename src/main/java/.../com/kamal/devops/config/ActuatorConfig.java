package com.kamal.devops.config;

import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.boot.actuate.autoconfigure.metrics.MeterRegistryCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Adds common tags to every Prometheus metric exported by this app.
 * In Grafana, you can then filter by application="kamalapp" or version="1.5.0"
 * when multiple services share the same Prometheus instance.
 */
@Configuration
public class ActuatorConfig {

    @Bean
    MeterRegistryCustomizer<MeterRegistry> metricsCommonTags() {
        return registry -> registry.config()
                .commonTags("application", "kamalapp", "version", "1.5.0");
    }
}
