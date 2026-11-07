package com.example.authetication.modelo;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.util.UUID;

@Entity
@Table(name = "usuario_preferencias")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioPreferencias {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false, unique = true)
    @JsonIgnore
    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    private Usuario usuario;

    // Privacy & Frequencies
    @Column(name = "private_frequency_mode", nullable = false)
    @Builder.Default
    private boolean privateFrequencyMode = false;

    @Column(name = "direct_transmissions", nullable = false)
    @Builder.Default
    private boolean directTransmissions = true;

    @Column(name = "broadcast_node_activity", nullable = false)
    @Builder.Default
    private boolean broadcastNodeActivity = true;

    // Transmission Alerts
    @Column(name = "push_transmissions", nullable = false)
    @Builder.Default
    private boolean pushTransmissions = true;

    @Column(name = "acoustic_echos", nullable = false)
    @Builder.Default
    private boolean acousticEchos = true;

    @Column(name = "zone_broadcast_alerts", nullable = false)
    @Builder.Default
    private boolean zoneBroadcastAlerts = false;

    // Security
    @Column(name = "two_factor_auth", nullable = false)
    @Builder.Default
    private boolean twoFactorAuth = false;

    // Appearance & Frequencies (Tema visual)
    @Enumerated(EnumType.STRING)
    @Column(name = "theme", nullable = false)
    @Builder.Default
    private TemaVisual theme = TemaVisual.RETRO_GREEN;

    // Profile Photo Preference (6 imagens fixas)
    @Column(name = "avatar_url")
    @Builder.Default
    private String avatarUrl = "lib/assets/images/avatars/avatar_1.webp";
}

