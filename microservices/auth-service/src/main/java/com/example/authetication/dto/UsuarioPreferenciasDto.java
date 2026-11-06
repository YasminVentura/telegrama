package com.example.authetication.dto;

import com.example.authetication.modelo.TemaVisual;
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
}

