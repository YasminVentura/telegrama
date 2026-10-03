package com.example.authetication.dto;

import lombok.Data;

@Data
public class PerfilRespostaDto {
    private String nome;
    private String nodeId;
    private String bio;
    private String localizacao;
    private long quantidadeSeguidores;
    private long quantidadeSeguindo;
}
