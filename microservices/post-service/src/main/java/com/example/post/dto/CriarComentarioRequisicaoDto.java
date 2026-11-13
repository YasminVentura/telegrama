package com.example.post.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CriarComentarioRequisicaoDto {

    @NotBlank(message = "O conteúdo do comentário não pode estar vazio.")
    @Size(max = 500, message = "O comentário deve ter no máximo 500 caracteres.")
    private String content;

    private String parentId;
}
