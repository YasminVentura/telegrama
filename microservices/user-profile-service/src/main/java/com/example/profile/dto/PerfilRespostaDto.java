package com.example.profile.dto;

import com.example.profile.modelo.Role;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerfilRespostaDto {
    private UUID id;
    private String nome;
    private String nodeId;
    private String email;
    private String bio;
    private String localizacao;
    private String avatarUrl;
    private String bannerColor;
    private Role perfil;
    private long quantidadeSeguidores;
    private long quantidadeSeguindo;

    @JsonProperty("isMe")
    private boolean isMe;

    @JsonProperty("isFollowing")
    private boolean seguindo;

    private UsuarioPreferenciasDto preferencias;
}
