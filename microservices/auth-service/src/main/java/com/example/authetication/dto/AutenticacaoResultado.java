package com.example.authetication.dto;

public record AutenticacaoResultado(
        String idSessao,
        UsuarioRespostaDto usuario
) {}
