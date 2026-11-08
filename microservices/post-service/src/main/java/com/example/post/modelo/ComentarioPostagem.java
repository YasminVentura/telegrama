package com.example.post.modelo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComentarioPostagem {

    private String id;

    private String parentId;

    private String autorId;

    private String autorNodeId;

    private String autorNome;

    private String autorAvatarUrl;

    private String conteudo;

    @Builder.Default
    private Set<String> curtidas = new HashSet<>();

    private LocalDateTime criadoEm;
}

