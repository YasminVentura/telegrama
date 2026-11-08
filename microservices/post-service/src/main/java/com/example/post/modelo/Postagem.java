package com.example.post.modelo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Document(collection = "postagens")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Postagem {

    @Id
    private String id;

    private String autorId;

    private String autorNodeId;

    private String autorNome;

    private String autorAvatarUrl;

    private String conteudo;

    @Builder.Default
    private Set<String> curtidas = new HashSet<>();

    @Builder.Default
    private Set<String> salvos = new HashSet<>();

    @Builder.Default
    private int quantidadeCurtidas = 0;

    @Builder.Default
    private int quantidadeComentarios = 0;

    @CreatedDate
    private LocalDateTime criadoEm;

    @LastModifiedDate
    private LocalDateTime atualizadoEm;
}
