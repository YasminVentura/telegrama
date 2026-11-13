package com.example.post.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ComentarioRespostaDto {

    private String id;

    private String parentId;

    private String authorName;

    private String authorId;

    private String authorAvatarUrl;

    private String content;

    private String createdAt;

    private int likes;

    private boolean curtidoPeloUsuario;

    @Builder.Default
    private List<ComentarioRespostaDto> replies = new ArrayList<>();
}
