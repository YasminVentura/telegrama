package com.example.authetication.controller;

import com.example.authetication.dto.LoginRequisicaoDto;
import com.example.authetication.dto.RegistroRequisicaoDto;
import com.example.authetication.dto.TokenRespostaDto;
import com.example.authetication.servico.AuthService;
import com.example.authetication.servico.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UsuarioService usuarioService;

    @PostMapping("/registro")
    @ResponseStatus(HttpStatus.CREATED)
    public void registrar(@RequestBody @Valid RegistroRequisicaoDto request) {
        usuarioService.registrar(request);
    }

    @PostMapping("/login")
    @ResponseStatus(HttpStatus.OK)
    public TokenRespostaDto login(@RequestBody @Valid LoginRequisicaoDto request) {
        return authService.autenticar(request);
    }
}
