package com.example.profile.modelo;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "perfis_usuarios")
@EntityListeners(AuditingEntityListener.class)
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerfilUsuario {

    @Id
    private UUID id;

    @Column(nullable = false)
    private String nome;

    @Column(name = "node_id", nullable = false, unique = true)
    private String nodeId;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(length = 500)
    private String bio;

    private String localizacao;

    @Column(name = "avatar_url")
    private String avatarUrl;

    @Column(name = "banner_color")
    @Builder.Default
    private String bannerColor = "#2E4F3E";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private Role perfil = Role.USER;

    @CreatedDate
    @Column(name = "criado_em", nullable = false, updatable = false)
    private LocalDateTime criadoEm;

    @LastModifiedDate
    @Column(name = "atualizado_em")
    private LocalDateTime atualizadoEm;

    @OneToOne(mappedBy = "usuario", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private UsuarioPreferencias preferencias;

    @PrePersist
    public void garantirId() {
        if (this.id == null) {
            this.id = UUID.randomUUID();
        }
    }
}
