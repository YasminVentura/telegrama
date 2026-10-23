package com.example.post.controller;

import com.example.post.dto.CriarPostagemRequisicaoDto;
import com.example.post.dto.PostagemRespostaDto;
import com.example.post.dto.RespostaEnvelopeDto;
import com.example.post.seguranca.UsuarioAutenticado;
import com.example.post.servico.PostagemService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping(path = {"/posts", "/api/posts"})
@RequiredArgsConstructor
public class PostagemController {

    private final PostagemService postagemService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public RespostaEnvelopeDto<PostagemRespostaDto> criarPostagem(
            @Valid @RequestBody CriarPostagemRequisicaoDto requisicao,
            Authentication authentication
    ) {
        UsuarioAutenticado autor = extrairUsuario(authentication);
        PostagemRespostaDto criado = postagemService.criarPostagem(requisicao, autor);
        return new RespostaEnvelopeDto<>(criado);
    }

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public RespostaEnvelopeDto<List<PostagemRespostaDto>> listarPostagens(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int limit,
            Authentication authentication
    ) {
        UsuarioAutenticado usuarioLogado = extrairUsuarioOpcional(authentication);
        List<PostagemRespostaDto> postagens = postagemService.listarPostagens(page, limit, usuarioLogado);
        return new RespostaEnvelopeDto<>(postagens);
    }

    @GetMapping("/{id}")
    @ResponseStatus(HttpStatus.OK)
    public RespostaEnvelopeDto<PostagemRespostaDto> buscarPorId(
            @PathVariable String id,
            Authentication authentication
    ) {
        UsuarioAutenticado usuarioLogado = extrairUsuarioOpcional(authentication);
        PostagemRespostaDto postagem = postagemService.buscarPorId(id, usuarioLogado);
        return new RespostaEnvelopeDto<>(postagem);
    }

    @PostMapping(path = {"/{id}/curtir", "/{id}/like"})
    @ResponseStatus(HttpStatus.OK)
    public RespostaEnvelopeDto<PostagemRespostaDto> alternarCurtida(
            @PathVariable String id,
            Authentication authentication
    ) {
        UsuarioAutenticado usuarioLogado = extrairUsuario(authentication);
        PostagemRespostaDto postagem = postagemService.alternarCurtida(id, usuarioLogado);
        return new RespostaEnvelopeDto<>(postagem);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluirPostagem(
            @PathVariable String id,
            Authentication authentication
    ) {
        UsuarioAutenticado usuarioLogado = extrairUsuario(authentication);
        postagemService.excluirPostagem(id, usuarioLogado);
    }

    private UsuarioAutenticado extrairUsuario(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof UsuarioAutenticado usuario) {
            return usuario;
        }
        throw new IllegalStateException("Usuário não autenticado.");
    }

    private UsuarioAutenticado extrairUsuarioOpcional(Authentication authentication) {
        if (authentication != null && authentication.getPrincipal() instanceof UsuarioAutenticado usuario) {
            return usuario;
        }
        return null;
    }
}
