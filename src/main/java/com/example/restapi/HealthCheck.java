package com.example.restapi;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
class EmployeeController {

    // Giữ lại constructor trống hoặc xóa nếu không dùng repository nữa
    public EmployeeController() {}

    @GetMapping("/health")
    public ResponseEntity<Void> healthCheck() {
        return ResponseEntity.ok().build();
    }
}
