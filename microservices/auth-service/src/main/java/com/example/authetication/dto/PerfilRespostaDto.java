package com.example.authetication.dto;

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
    private long quantidadeSeguidores;
    private long quantidadeSeguindo;

    @JsonProperty("isMe")
    private boolean isMe;

    private UsuarioPreferenciasDto preferencias;
}
