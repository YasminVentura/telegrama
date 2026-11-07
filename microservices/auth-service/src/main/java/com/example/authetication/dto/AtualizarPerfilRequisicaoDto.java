package com.example.authetication.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AtualizarPerfilRequisicaoDto {
    private String nome;
    private String bio;
    private String localizacao;

    @JsonAlias({"fotoPerfil", "profilePhoto", "avatar", "avatar_url"})
    private String avatarUrl;

    private UsuarioPreferenciasDto preferencias;
}

