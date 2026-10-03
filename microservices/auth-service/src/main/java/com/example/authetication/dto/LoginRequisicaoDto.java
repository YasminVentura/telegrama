package com.example.authetication.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class LoginRequisicaoDto {

    @NotBlank(message = "O identificador (email ou node_id) é obrigatório.")
    private String identificador;

    @NotBlank(message = "A senha é obrigatória.")
    private String senha;
}
