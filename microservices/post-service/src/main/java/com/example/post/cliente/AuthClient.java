package com.example.post.cliente;

import com.example.post.dto.PerfilResumidoDto;
import com.example.post.dto.RespostaEnvelopeDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

import java.util.List;

@FeignClient(name = "user-profile-service")
public interface AuthClient {

    @PostMapping("/usuarios/batch")
    RespostaEnvelopeDto<List<PerfilResumidoDto>> buscarPerfisEmLote(@RequestBody List<String> ids);
}
