package com.example.authetication.controller;

import com.example.authetication.dto.PerfilRespostaDto;
import com.example.authetication.servico.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @GetMapping("/{nodeId}")
    @ResponseStatus(HttpStatus.OK)
    public PerfilRespostaDto buscarPerfil(@PathVariable String nodeId) {
        return usuarioService.buscarPerfil(nodeId);
    }

    @DeleteMapping("/{nodeId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluirConta(@PathVariable String nodeId, Authentication authentication) {
        // authentication.getName() retorna o Username definido no DetalhesUsuarioImpl (que é o nodeId)
        String nodeIdSolicitante = authentication.getName();
        usuarioService.excluirConta(nodeId, nodeIdSolicitante);
    }
}
