package com.example.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.io.File;

@RestController
class HealthCheck {

    @GetMapping("/health")
    public ResponseEntity<Void> healthCheck() {
        return ResponseEntity.ok().build();
    }

    @GetMapping("/info")
    public ResponseEntity<Map<String, String>> info() {
        String buildTool = "Unknown";
        if (new File("pom.xml").exists()) {
            buildTool = "Maven";
        } else if (new File("build.gradle").exists() || new File("build.gradle.kts").exists()) {
            buildTool = "Gradle";
        }

        Map<String, String> appInfo = Map.of(
            "appName", "Employee Management API",
            "javaVersion", System.getProperty("java.version"),
            "buildTool", buildTool,
            "status", "Running"
        );

        return ResponseEntity.ok(appInfo);
    }
}
