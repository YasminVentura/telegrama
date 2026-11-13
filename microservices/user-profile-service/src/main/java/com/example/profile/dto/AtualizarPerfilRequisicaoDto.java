package com.example.profile.dto;

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

    @JsonAlias({"corCapa", "banner_color"})
    private String bannerColor;

    private UsuarioPreferenciasDto preferencias;
}
