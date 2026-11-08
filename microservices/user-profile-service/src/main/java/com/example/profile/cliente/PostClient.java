package com.example.profile.cliente;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;

@FeignClient(name = "post-service")
public interface PostClient {

    @DeleteMapping("/posts/interno/autor/{nodeId}")
    void excluirPostagensPorAutor(@PathVariable("nodeId") String nodeId);
}

