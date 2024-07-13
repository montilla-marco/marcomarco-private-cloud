package org.marcomarco.blog.microservice.hello.web;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class ControllerV1 {

    @GetMapping("/welcome")
    public String sayWelcome(){
        return "Welcome to Spring Application with Security";
    }
}
