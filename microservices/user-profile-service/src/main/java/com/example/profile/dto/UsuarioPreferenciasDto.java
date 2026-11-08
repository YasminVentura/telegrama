package com.example.profile.dto;

import com.example.profile.modelo.TemaVisual;
import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UsuarioPreferenciasDto {
    private Boolean privateFrequencyMode;
    private Boolean directTransmissions;
    private Boolean broadcastNodeActivity;
    private Boolean pushTransmissions;
    private Boolean acousticEchos;
    private Boolean zoneBroadcastAlerts;
    private Boolean twoFactorAuth;
    private TemaVisual theme;

    @JsonAlias({"fotoPerfil", "profilePhoto", "avatar", "avatar_url"})
    private String avatarUrl;

    @JsonAlias({"corCapa", "banner_color"})
    private String bannerColor;
}

