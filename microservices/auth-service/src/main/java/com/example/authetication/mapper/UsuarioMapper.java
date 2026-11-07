package com.example.authetication.mapper;

import com.example.authetication.dto.PerfilRespostaDto;
import com.example.authetication.dto.RegistroRequisicaoDto;
import com.example.authetication.dto.UsuarioPreferenciasDto;
import com.example.authetication.modelo.Usuario;
import com.example.authetication.modelo.UsuarioPreferencias;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface UsuarioMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "criadoEm", ignore = true)
    @Mapping(target = "atualizadoEm", ignore = true)
    @Mapping(target = "bio", ignore = true)
    @Mapping(target = "localizacao", ignore = true)
    @Mapping(target = "preferencias", ignore = true)
    Usuario paraEntidade(RegistroRequisicaoDto dto);

    // As quantidades de seguidores, isMe e seguindo serão preenchidas no service após o mapeamento básico
    @Mapping(target = "quantidadeSeguidores", ignore = true)
    @Mapping(target = "quantidadeSeguindo", ignore = true)
    @Mapping(target = "isMe", ignore = true)
    @Mapping(target = "seguindo", ignore = true)
    @Mapping(target = "preferencias", ignore = true)
    PerfilRespostaDto paraPerfilDto(Usuario usuario);

    UsuarioPreferenciasDto paraPreferenciasDto(UsuarioPreferencias preferencias);
}
