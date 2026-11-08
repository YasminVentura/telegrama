package com.example.authetication.dto;

public record AutenticacaoResultado(
        String idSessao,
        String refreshToken,
        UsuarioRespostaDto usuario
) {}
