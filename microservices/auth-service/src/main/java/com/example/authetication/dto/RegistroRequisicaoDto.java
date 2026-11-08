package com.example.authetication.dto;

import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegistroRequisicaoDto {

    @NotBlank(message = "O nome é obrigatório.")
    private String nome;

    @NotBlank(message = "O node_id (usuário) é obrigatório.")
    @Pattern(regexp = "^@?[a-zA-Z0-9_]{3,20}$", message = "O node_id deve conter apenas letras, números e underline (3 a 20 caracteres), com ou sem @.")
    private String nodeId;

    @NotBlank(message = "O email é obrigatório.")
    @Email(message = "Email com formato inválido.")
    private String email;

    @NotBlank(message = "A senha é obrigatória.")
    @Size(min = 8, message = "A senha deve ter no mínimo 8 caracteres.")
    @Pattern(
        regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=!]).{8,}$",
        message = "A senha deve conter ao menos um número, uma letra minúscula, uma letra maiúscula e um caractere especial."
    )
    private String senha;

    @AssertTrue(message = "Os termos de uso devem ser aceitos.")
    private Boolean termosAceitos;
}
