package com.example.authetication.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerfilResumidoDto {
    private String id;
    private String nome;
    private String nodeId;
    private String avatarUrl;
}