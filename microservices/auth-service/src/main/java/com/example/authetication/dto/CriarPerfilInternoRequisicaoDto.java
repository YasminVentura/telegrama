package com.example.authetication.dto;

import com.example.authetication.modelo.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CriarPerfilInternoRequisicaoDto {
    private UUID id;
    private String nome;
    private String nodeId;
    private String email;
    private String avatarUrl;
    private Role perfil;
}

