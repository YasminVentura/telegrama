package com.example.authetication.controller;

import com.example.authetication.dto.AtualizarPerfilRequisicaoDto;
import com.example.authetication.dto.PerfilRespostaDto;
import com.example.authetication.dto.PerfilResumidoDto;
import com.example.authetication.dto.RespostaEnvelopeDto; // Importação adicionada
import com.example.authetication.dto.UsuarioPreferenciasDto;
import com.example.authetication.excecao.RegraNegocioException;
import com.example.authetication.servico.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@CrossOrigin(
    originPatterns = {"http://localhost:*", "http://127.0.0.1:*"},
    allowedHeaders = "*",
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS},
    exposedHeaders = {"Set-Cookie", "X-Session-Id"},
    allowCredentials = "true"
)
@RestController
@RequestMapping("/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;

    @GetMapping("/me")
    @ResponseStatus(HttpStatus.OK)
    public PerfilRespostaDto buscarMeuPerfil(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }
        String nodeIdSolicitante = authentication.getName();
        return usuarioService.buscarPerfil(nodeIdSolicitante, nodeIdSolicitante);
    }

    @PutMapping("/me")
    @ResponseStatus(HttpStatus.OK)
    public PerfilRespostaDto atualizarMeuPerfil(
            @Valid @RequestBody AtualizarPerfilRequisicaoDto requisicao,
            Authentication authentication
    ) {
        if (authentication == null || authentication.getName() == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }
        String nodeIdSolicitante = authentication.getName();
        return usuarioService.atualizarPerfil(nodeIdSolicitante, requisicao);
    }

    @GetMapping("/me/preferences")
    @ResponseStatus(HttpStatus.OK)
    public UsuarioPreferenciasDto buscarMinhasPreferencias(Authentication authentication) {
        if (authentication == null || authentication.getName() == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }
        String nodeIdSolicitante = authentication.getName();
        return usuarioService.buscarPreferencias(nodeIdSolicitante);
    }

    @PutMapping("/me/preferences")
    @ResponseStatus(HttpStatus.OK)
    public UsuarioPreferenciasDto atualizarMinhasPreferencias(
            @RequestBody UsuarioPreferenciasDto dto,
            Authentication authentication
    ) {
        if (authentication == null || authentication.getName() == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }
        String nodeIdSolicitante = authentication.getName();
        return usuarioService.atualizarPreferencias(nodeIdSolicitante, dto);
    }

    @GetMapping(path = {"/busca", "/search"})
    @ResponseStatus(HttpStatus.OK)
    public RespostaEnvelopeDto<List<PerfilResumidoDto>> buscarUsuarios(
            @RequestParam(name = "q", defaultValue = "") String query
    ) {
        List<PerfilResumidoDto> resultado = usuarioService.buscarUsuariosPorTermo(query);
        return new RespostaEnvelopeDto<>(resultado);
    }

    @GetMapping("/{nodeId}")
    @ResponseStatus(HttpStatus.OK)
    public PerfilRespostaDto buscarPerfil(@PathVariable String nodeId, Authentication authentication) {
        String nodeIdSolicitante = authentication != null ? authentication.getName() : null;
        return usuarioService.buscarPerfil(nodeId, nodeIdSolicitante);
    }

    @DeleteMapping("/{nodeId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluirConta(@PathVariable String nodeId, Authentication authentication) {
        String nodeIdSolicitante = authentication.getName();
        usuarioService.excluirConta(nodeId, nodeIdSolicitante);
    }

    @PostMapping("/{nodeId}/seguir")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void seguirUsuario(@PathVariable String nodeId, Authentication authentication) {
        String nodeIdSolicitante = authentication.getName();
        usuarioService.seguirUsuario(nodeId, nodeIdSolicitante);
    }

    @DeleteMapping("/{nodeId}/seguir")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deixarDeSeguirUsuario(@PathVariable String nodeId, Authentication authentication) {
        String nodeIdSolicitante = authentication.getName();
        usuarioService.deixarDeSeguirUsuario(nodeId, nodeIdSolicitante);
    }

    @PostMapping("/batch")
    @ResponseStatus(HttpStatus.OK)
    public RespostaEnvelopeDto<List<PerfilResumidoDto>> buscarPerfisEmLote(
            @RequestBody List<String> ids
    ) {
        List<PerfilResumidoDto> perfis = usuarioService.buscarPerfisPorIds(ids);
        return new RespostaEnvelopeDto<>(perfis);
    }
}