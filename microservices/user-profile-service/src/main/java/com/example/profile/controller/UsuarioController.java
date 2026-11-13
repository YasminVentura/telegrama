package com.example.profile.controller;

import com.example.profile.dto.AtualizarPerfilRequisicaoDto;
import com.example.profile.dto.CriarPerfilInternoRequisicaoDto;
import com.example.profile.dto.PerfilRespostaDto;
import com.example.profile.dto.PerfilResumidoDto;
import com.example.profile.dto.RespostaEnvelopeDto;
import com.example.profile.dto.UsuarioPreferenciasDto;
import com.example.profile.excecao.RegraNegocioException;
import com.example.profile.seguranca.UsuarioAutenticado;
import com.example.profile.servico.PerfilUsuarioService;
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

    private final PerfilUsuarioService perfilUsuarioService;

    @PostMapping("/interno/perfil")
    @ResponseStatus(HttpStatus.CREATED)
    public PerfilRespostaDto criarOuSincronizarPerfilInterno(
            @RequestBody CriarPerfilInternoRequisicaoDto requisicao
    ) {
        return perfilUsuarioService.criarOuSincronizarPerfilInterno(requisicao);
    }

    @GetMapping("/me")
    @ResponseStatus(HttpStatus.OK)
    public PerfilRespostaDto buscarMeuPerfil(Authentication authentication) {
        UsuarioAutenticado usuario = extrairUsuarioAutenticado(authentication);
        return perfilUsuarioService.buscarMeuPerfil(usuario);
    }

    @PutMapping("/me")
    @ResponseStatus(HttpStatus.OK)
    public PerfilRespostaDto atualizarMeuPerfil(
            @Valid @RequestBody AtualizarPerfilRequisicaoDto requisicao,
            Authentication authentication
    ) {
        UsuarioAutenticado usuario = extrairUsuarioAutenticado(authentication);
        return perfilUsuarioService.atualizarPerfil(usuario, requisicao);
    }

    @GetMapping("/me/preferences")
    @ResponseStatus(HttpStatus.OK)
    public UsuarioPreferenciasDto buscarMinhasPreferencias(Authentication authentication) {
        UsuarioAutenticado usuario = extrairUsuarioAutenticado(authentication);
        return perfilUsuarioService.buscarPreferencias(usuario);
    }

    @PutMapping("/me/preferences")
    @ResponseStatus(HttpStatus.OK)
    public UsuarioPreferenciasDto atualizarMinhasPreferencias(
            @RequestBody UsuarioPreferenciasDto dto,
            Authentication authentication
    ) {
        UsuarioAutenticado usuario = extrairUsuarioAutenticado(authentication);
        return perfilUsuarioService.atualizarPreferencias(usuario, dto);
    }

    @GetMapping(path = {"/busca", "/search"})
    @ResponseStatus(HttpStatus.OK)
    public RespostaEnvelopeDto<List<PerfilResumidoDto>> buscarUsuarios(
            @RequestParam(name = "q", defaultValue = "") String query
    ) {
        List<PerfilResumidoDto> resultado = perfilUsuarioService.buscarUsuariosPorTermo(query);
        return new RespostaEnvelopeDto<>(resultado);
    }

    @GetMapping("/{nodeId}")
    @ResponseStatus(HttpStatus.OK)
    public PerfilRespostaDto buscarPerfil(@PathVariable String nodeId, Authentication authentication) {
        String nodeIdSolicitante = authentication != null ? authentication.getName() : null;
        return perfilUsuarioService.buscarPerfil(nodeId, nodeIdSolicitante);
    }

    @DeleteMapping("/{nodeId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluirConta(@PathVariable String nodeId, Authentication authentication) {
        UsuarioAutenticado usuario = extrairUsuarioAutenticado(authentication);
        perfilUsuarioService.excluirConta(nodeId, usuario);
    }

    @PostMapping("/{nodeId}/seguir")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void seguirUsuario(@PathVariable String nodeId, Authentication authentication) {
        UsuarioAutenticado usuario = extrairUsuarioAutenticado(authentication);
        perfilUsuarioService.seguirUsuario(nodeId, usuario);
    }

    @DeleteMapping("/{nodeId}/seguir")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deixarDeSeguirUsuario(@PathVariable String nodeId, Authentication authentication) {
        UsuarioAutenticado usuario = extrairUsuarioAutenticado(authentication);
        perfilUsuarioService.deixarDeSeguirUsuario(nodeId, usuario);
    }

    @PostMapping("/batch")
    @ResponseStatus(HttpStatus.OK)
    public RespostaEnvelopeDto<List<PerfilResumidoDto>> buscarPerfisEmLote(
            @RequestBody List<String> ids
    ) {
        List<PerfilResumidoDto> perfis = perfilUsuarioService.buscarPerfisPorIds(ids);
        return new RespostaEnvelopeDto<>(perfis);
    }

    private UsuarioAutenticado extrairUsuarioAutenticado(Authentication authentication) {
        if (authentication == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }
        if (authentication.getPrincipal() instanceof UsuarioAutenticado usuario) {
            return usuario;
        }
        if (authentication.getName() != null) {
            return UsuarioAutenticado.builder()
                    .nodeId(authentication.getName())
                    .nome(authentication.getName())
                    .build();
        }
        throw new RegraNegocioException("Usuário não autenticado.");
    }
}
