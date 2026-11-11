package com.example.profile.mapper;

import com.example.profile.dto.PerfilRespostaDto;
import com.example.profile.dto.UsuarioPreferenciasDto;
import com.example.profile.modelo.PerfilUsuario;
import com.example.profile.modelo.UsuarioPreferencias;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2026-11-11T19:12:13-0300",
    comments = "version: 1.5.5.Final, compiler: Eclipse JDT (IDE) 3.46.200.v20261008-1115, environment: Java 25.0.4.1 (Eclipse Adoptium)"
)
@Component
public class PerfilUsuarioMapperImpl implements PerfilUsuarioMapper {

    @Override
    public PerfilRespostaDto paraPerfilDto(PerfilUsuario usuario) {
        if ( usuario == null ) {
            return null;
        }

        PerfilRespostaDto.PerfilRespostaDtoBuilder perfilRespostaDto = PerfilRespostaDto.builder();

        perfilRespostaDto.avatarUrl( usuario.getAvatarUrl() );
        perfilRespostaDto.bannerColor( usuario.getBannerColor() );
        perfilRespostaDto.bio( usuario.getBio() );
        perfilRespostaDto.email( usuario.getEmail() );
        perfilRespostaDto.id( usuario.getId() );
        perfilRespostaDto.localizacao( usuario.getLocalizacao() );
        perfilRespostaDto.nodeId( usuario.getNodeId() );
        perfilRespostaDto.nome( usuario.getNome() );
        perfilRespostaDto.perfil( usuario.getPerfil() );

        return perfilRespostaDto.build();
    }

    @Override
    public UsuarioPreferenciasDto paraPreferenciasDto(UsuarioPreferencias preferencias) {
        if ( preferencias == null ) {
            return null;
        }

        UsuarioPreferenciasDto.UsuarioPreferenciasDtoBuilder usuarioPreferenciasDto = UsuarioPreferenciasDto.builder();

        usuarioPreferenciasDto.acousticEchos( preferencias.isAcousticEchos() );
        usuarioPreferenciasDto.avatarUrl( preferencias.getAvatarUrl() );
        usuarioPreferenciasDto.bannerColor( preferencias.getBannerColor() );
        usuarioPreferenciasDto.broadcastNodeActivity( preferencias.isBroadcastNodeActivity() );
        usuarioPreferenciasDto.directTransmissions( preferencias.isDirectTransmissions() );
        usuarioPreferenciasDto.privateFrequencyMode( preferencias.isPrivateFrequencyMode() );
        usuarioPreferenciasDto.pushTransmissions( preferencias.isPushTransmissions() );
        usuarioPreferenciasDto.theme( preferencias.getTheme() );
        usuarioPreferenciasDto.twoFactorAuth( preferencias.isTwoFactorAuth() );
        usuarioPreferenciasDto.zoneBroadcastAlerts( preferencias.isZoneBroadcastAlerts() );

        return usuarioPreferenciasDto.build();
    }
}
