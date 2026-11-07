package com.example.authetication.servico;

import java.util.Optional;
import java.util.UUID;
import com.example.authetication.cliente.UserProfileClient;
import com.example.authetication.dto.CriarPerfilInternoRequisicaoDto;
import com.example.authetication.dto.RegistroRequisicaoDto;
import com.example.authetication.excecao.RegraNegocioException;
import com.example.authetication.mapper.UsuarioMapper;
import com.example.authetication.modelo.Usuario;
import com.example.authetication.repositorio.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UsuarioService {

    public static final String AVATAR_PADRAO = "lib/assets/images/avatars/avatar_1.webp";

    private final UsuarioRepository usuarioRepository;
    private final UsuarioMapper usuarioMapper;
    private final PasswordEncoder passwordEncoder;
    private final UserProfileClient userProfileClient;

    @Transactional
    public void registrar(RegistroRequisicaoDto dto) {
        if (!dto.getTermosAceitos()) {
            throw new RegraNegocioException("Você deve aceitar os termos de uso.");
        }
        if (usuarioRepository.existsByEmail(dto.getEmail())) {
            throw new RegraNegocioException("E-mail já cadastrado.");
        }
        if (usuarioRepository.existsByNodeId(dto.getNodeId())) {
            throw new RegraNegocioException("Node ID (usuário) já está em uso.");
        }

        Usuario usuario = usuarioMapper.paraEntidade(dto);
        usuario.setSenha(passwordEncoder.encode(dto.getSenha()));

        Usuario salvo = usuarioRepository.save(usuario);

        try {
            userProfileClient.criarOuSincronizarPerfil(
                    CriarPerfilInternoRequisicaoDto.builder()
                            .id(salvo.getId())
                            .nome(salvo.getNome())
                            .nodeId(salvo.getNodeId())
                            .email(salvo.getEmail())
                            .avatarUrl(AVATAR_PADRAO)
                            .perfil(salvo.getPerfil())
                            .build()
            );
        } catch (Exception e) {
            log.warn("Aviso ao provisionar perfil inicial no user-profile-service: {}", e.getMessage());
        }
    }

    @Transactional
    public void excluirCredencialInterna(String identificador) {
        encontrarUsuarioPorNodeIdOuId(identificador).ifPresent(usuarioRepository::delete);
    }

    public Optional<Usuario> encontrarUsuarioPorNodeIdOuId(String identificador) {
        if (identificador == null || identificador.isBlank()) {
            return Optional.empty();
        }
        String limpo = identificador.trim();

        try {
            UUID uuid = UUID.fromString(limpo);
            Optional<Usuario> porUuid = usuarioRepository.findById(uuid);
            if (porUuid.isPresent()) {
                return porUuid;
            }
        } catch (IllegalArgumentException ignored) {
        }

        Optional<Usuario> usuario = usuarioRepository.findByNodeId(limpo);
        if (usuario.isPresent()) {
            return usuario;
        }

        if (limpo.startsWith("@")) {
            usuario = usuarioRepository.findByNodeId(limpo.substring(1));
        } else {
            usuario = usuarioRepository.findByNodeId("@" + limpo);
        }
        if (usuario.isPresent()) {
            return usuario;
        }

        return usuarioRepository.findByEmail(limpo);
    }
}
