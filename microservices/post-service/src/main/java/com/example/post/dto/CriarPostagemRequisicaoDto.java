package com.example.post.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CriarPostagemRequisicaoDto {

    @NotBlank(message = "O conteúdo da publicação não pode ser vazio")
    @Size(max = 500, message = "O conteúdo deve conter no máximo 500 caracteres")
    @JsonAlias({"conteudo", "texto", "text"})
    private String content;

    public String getConteudo() {
        return content;
    }

    public void setConteudo(String conteudo) {
        this.content = conteudo;
    }
}
