package com.example.profile.cliente;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "auth-service")
public interface AuthClient {

    @DeleteMapping("/auth/interno/usuarios/{identificador}")
    void excluirCredencialInterna(@PathVariable("identificador") String identificador);
}

