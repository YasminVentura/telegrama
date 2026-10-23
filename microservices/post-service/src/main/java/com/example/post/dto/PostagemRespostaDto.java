package com.example.post.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostagemRespostaDto {

    private String id;

    @JsonProperty("author_name")
    private String authorName;

    @JsonProperty("author_id")
    private String authorId;

    @JsonProperty("author_avatar_url")
    private String authorAvatarUrl;

    private String content;

    @JsonProperty("created_at")
    private String createdAt;

    @JsonProperty("updated_at")
    private String updatedAt;

    private int likes;

    private int comments;

    @JsonProperty("likesCount")
    public int getLikesCount() {
        return likes;
    }

    @JsonProperty("commentsCount")
    public int getCommentsCount() {
        return comments;
    }

    @JsonProperty("authorName")
    public String getAuthorNameCamel() {
        return authorName;
    }

    @JsonProperty("authorHandle")
    public String getAuthorHandle() {
        return authorId;
    }

    @JsonProperty("authorId")
    public String getAuthorIdCamel() {
        return authorId;
    }

    @JsonProperty("conteudo")
    public String getConteudo() {
        return content;
    }

    @JsonProperty("criadoEm")
    public String getCriadoEm() {
        return createdAt;
    }

    @JsonProperty("curtidoPeloUsuario")
    private boolean curtidoPeloUsuario;
}
