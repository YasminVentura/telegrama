package com.example.authetication.dto;

import com.example.authetication.modelo.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class UsuarioRespostaDto {
    private UUID id;
    private String nome;
    private String nodeId;
    private String email;
    private Role perfil;
    private String idSessao;
}
