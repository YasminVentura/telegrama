package com.example.post.modelo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Field;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComentarioPostagem {

    @Id
    @Field("_id")
    private String id;

    @Field("id")
    private String idLegado;

    private String parentId;

    private String autorId;

    private String autorNodeId;

    private String autorNome;

    private String autorAvatarUrl;

    private String conteudo;

    @Builder.Default
    private Set<String> curtidas = new HashSet<>();

    private LocalDateTime criadoEm;

    public String getId() {
        if (id != null && !id.isBlank()) {
            return id;
        }
        return idLegado;
    }
}

