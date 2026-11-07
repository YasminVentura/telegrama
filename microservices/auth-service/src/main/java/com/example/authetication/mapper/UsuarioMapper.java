package com.example.authetication.mapper;

import com.example.authetication.dto.RegistroRequisicaoDto;
import com.example.authetication.modelo.Usuario;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingConstants;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface UsuarioMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "criadoEm", ignore = true)
    @Mapping(target = "atualizadoEm", ignore = true)
    @Mapping(target = "perfil", ignore = true)
    Usuario paraEntidade(RegistroRequisicaoDto dto);
}
