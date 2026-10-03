package com.example.authetication;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class AutheticationApplication {

	public static void main(String[] args) {
		SpringApplication.run(AutheticationApplication.class, args);
	}

}
