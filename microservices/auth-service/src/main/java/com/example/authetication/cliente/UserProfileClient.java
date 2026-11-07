package com.example.authetication.cliente;

import com.example.authetication.dto.CriarPerfilInternoRequisicaoDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "user-profile-service")
public interface UserProfileClient {

    @PostMapping("/usuarios/interno/perfil")
    void criarOuSincronizarPerfil(@RequestBody CriarPerfilInternoRequisicaoDto requisicao);
}
