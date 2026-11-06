package com.example.authetication.dto;

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
    private UsuarioPreferenciasDto preferencias;
}

