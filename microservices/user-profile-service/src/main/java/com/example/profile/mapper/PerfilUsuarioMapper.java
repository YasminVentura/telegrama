package com.example.profile.mapper;

import com.example.profile.dto.PerfilRespostaDto;
import com.example.profile.dto.UsuarioPreferenciasDto;
import com.example.profile.modelo.PerfilUsuario;
import com.example.profile.modelo.UsuarioPreferencias;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface PerfilUsuarioMapper {

    @Mapping(target = "quantidadeSeguidores", ignore = true)
    @Mapping(target = "quantidadeSeguindo", ignore = true)
    @Mapping(target = "isMe", ignore = true)
    @Mapping(target = "seguindo", ignore = true)
    @Mapping(target = "preferencias", ignore = true)
    PerfilRespostaDto paraPerfilDto(PerfilUsuario usuario);

    UsuarioPreferenciasDto paraPreferenciasDto(UsuarioPreferencias preferencias);
}
