package com.example.authetication.servico;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import com.example.authetication.dto.AtualizarPerfilRequisicaoDto;
import com.example.authetication.dto.PerfilRespostaDto;
import com.example.authetication.dto.PerfilResumidoDto;
import com.example.authetication.dto.RegistroRequisicaoDto;
import com.example.authetication.dto.UsuarioPreferenciasDto;
import com.example.authetication.excecao.RegraNegocioException;
import com.example.authetication.mapper.UsuarioMapper;
import com.example.authetication.modelo.Seguidor;
import com.example.authetication.modelo.TemaVisual;
import com.example.authetication.modelo.Usuario;
import com.example.authetication.modelo.UsuarioPreferencias;
import com.example.authetication.repositorio.SeguidorRepository;
import com.example.authetication.repositorio.UsuarioPreferenciasRepository;
import com.example.authetication.repositorio.UsuarioRepository;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final SeguidorRepository seguidorRepository;
    private final UsuarioPreferenciasRepository usuarioPreferenciasRepository;
    private final UsuarioMapper usuarioMapper;
    private final PasswordEncoder passwordEncoder;

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
        
        UsuarioPreferencias preferenciasPadrao = UsuarioPreferencias.builder()
                .usuario(usuario)
                .privateFrequencyMode(false)
                .directTransmissions(true)
                .broadcastNodeActivity(true)
                .pushTransmissions(true)
                .acousticEchos(true)
                .zoneBroadcastAlerts(false)
                .twoFactorAuth(false)
                .theme(TemaVisual.RETRO_GREEN)
                .build();
        usuario.setPreferencias(preferenciasPadrao);

        usuarioRepository.save(usuario);
    }

    @Transactional(readOnly = true)
    public PerfilRespostaDto buscarPerfil(String nodeId) {
        return buscarPerfil(nodeId, null);
    }

    @Transactional
    public PerfilRespostaDto buscarPerfil(String nodeIdAlvo, String nodeIdSolicitante) {
        Usuario usuario = usuarioRepository.findByNodeId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado."));

        PerfilRespostaDto perfilDto = usuarioMapper.paraPerfilDto(usuario);
        
        long seguidores = seguidorRepository.countBySeguido(usuario);
        long seguindo = seguidorRepository.countBySeguidor(usuario);
        
        perfilDto.setQuantidadeSeguidores(seguidores);
        perfilDto.setQuantidadeSeguindo(seguindo);

        boolean isMe = nodeIdSolicitante != null && nodeIdSolicitante.equals(usuario.getNodeId());
        perfilDto.setMe(isMe);

        if (isMe) {
            UsuarioPreferencias preferencias = usuario.getPreferencias();
            if (preferencias == null) {
                preferencias = obterOuCriarPreferencias(usuario);
            }
            perfilDto.setPreferencias(usuarioMapper.paraPreferenciasDto(preferencias));
        }
        
        return perfilDto;
    }

    @Transactional
    public UsuarioPreferenciasDto buscarPreferencias(String nodeId) {
        Usuario usuario = usuarioRepository.findByNodeId(nodeId)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado."));

        UsuarioPreferencias preferencias = usuario.getPreferencias();
        if (preferencias == null) {
            preferencias = obterOuCriarPreferencias(usuario);
        }

        return usuarioMapper.paraPreferenciasDto(preferencias);
    }

    @Transactional
    public PerfilRespostaDto atualizarPerfil(String nodeIdSolicitante, AtualizarPerfilRequisicaoDto dto) {
        Usuario usuario = usuarioRepository.findByNodeId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado."));

        if (dto.getNome() != null && !dto.getNome().isBlank()) {
            usuario.setNome(dto.getNome().trim());
        }
        if (dto.getBio() != null) {
            usuario.setBio(dto.getBio().trim());
        }
        if (dto.getLocalizacao() != null) {
            usuario.setLocalizacao(dto.getLocalizacao().trim());
        }

        if (dto.getPreferencias() != null) {
            UsuarioPreferencias prefs = usuario.getPreferencias();
            if (prefs == null) {
                prefs = obterOuCriarPreferencias(usuario);
            }
            atualizarCamposPreferencias(prefs, dto.getPreferencias());
            usuario.setPreferencias(prefs);
        }

        Usuario salvo = usuarioRepository.save(usuario);
        PerfilRespostaDto resposta = usuarioMapper.paraPerfilDto(salvo);
        
        long seguidores = seguidorRepository.countBySeguido(salvo);
        long seguindo = seguidorRepository.countBySeguidor(salvo);
        resposta.setQuantidadeSeguidores(seguidores);
        resposta.setQuantidadeSeguindo(seguindo);
        resposta.setMe(true);
        if (salvo.getPreferencias() != null) {
            resposta.setPreferencias(usuarioMapper.paraPreferenciasDto(salvo.getPreferencias()));
        }

        return resposta;
    }

    @Transactional
    public UsuarioPreferenciasDto atualizarPreferencias(String nodeIdSolicitante, UsuarioPreferenciasDto dto) {
        Usuario usuario = usuarioRepository.findByNodeId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado."));

        UsuarioPreferencias prefs = usuario.getPreferencias();
        if (prefs == null) {
            prefs = obterOuCriarPreferencias(usuario);
        }

        atualizarCamposPreferencias(prefs, dto);
        UsuarioPreferencias salva = usuarioPreferenciasRepository.save(prefs);
        return usuarioMapper.paraPreferenciasDto(salva);
    }

    private void atualizarCamposPreferencias(UsuarioPreferencias prefs, UsuarioPreferenciasDto dto) {
        if (dto.getPrivateFrequencyMode() != null) {
            prefs.setPrivateFrequencyMode(dto.getPrivateFrequencyMode());
        }
        if (dto.getDirectTransmissions() != null) {
            prefs.setDirectTransmissions(dto.getDirectTransmissions());
        }
        if (dto.getBroadcastNodeActivity() != null) {
            prefs.setBroadcastNodeActivity(dto.getBroadcastNodeActivity());
        }
        if (dto.getPushTransmissions() != null) {
            prefs.setPushTransmissions(dto.getPushTransmissions());
        }
        if (dto.getAcousticEchos() != null) {
            prefs.setAcousticEchos(dto.getAcousticEchos());
        }
        if (dto.getZoneBroadcastAlerts() != null) {
            prefs.setZoneBroadcastAlerts(dto.getZoneBroadcastAlerts());
        }
        if (dto.getTwoFactorAuth() != null) {
            prefs.setTwoFactorAuth(dto.getTwoFactorAuth());
        }
        if (dto.getTheme() != null) {
            prefs.setTheme(dto.getTheme());
        }
    }

    private UsuarioPreferencias obterOuCriarPreferencias(Usuario usuario) {
        return usuarioPreferenciasRepository.findByUsuario(usuario)
                .orElseGet(() -> {
                    UsuarioPreferencias nova = UsuarioPreferencias.builder()
                            .usuario(usuario)
                            .privateFrequencyMode(false)
                            .directTransmissions(true)
                            .broadcastNodeActivity(true)
                            .pushTransmissions(true)
                            .acousticEchos(true)
                            .zoneBroadcastAlerts(false)
                            .twoFactorAuth(false)
                            .theme(TemaVisual.RETRO_GREEN)
                            .build();
                    return usuarioPreferenciasRepository.save(nova);
                });
    }

    @Transactional
    public void excluirConta(String nodeIdAlvo, String nodeIdSolicitante) {
        Usuario alvo = usuarioRepository.findByNodeId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado."));

        Usuario solicitante = usuarioRepository.findByNodeId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário solicitante não encontrado."));

        if (!alvo.getId().equals(solicitante.getId()) && solicitante.getPerfil() != com.example.authetication.modelo.Role.ADMIN) {
            throw new RegraNegocioException("Sem permissão para excluir esta conta. Apenas o proprietário ou um administrador podem realizar esta ação.");
        }

        usuarioRepository.delete(alvo);
    }

    @Transactional
    public void seguirUsuario(String nodeIdAlvo, String nodeIdSolicitante) {
        if (nodeIdAlvo.equals(nodeIdSolicitante)) {
            throw new RegraNegocioException("Você não pode seguir a si mesmo.");
        }

        Usuario alvo = usuarioRepository.findByNodeId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado."));
        Usuario solicitante = usuarioRepository.findByNodeId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário solicitante não encontrado."));

        if (seguidorRepository.existsBySeguidorAndSeguido(solicitante, alvo)) {
            throw new RegraNegocioException("Você já segue este usuário.");
        }

        Seguidor novoSeguidor = Seguidor.builder()
                .seguidor(solicitante)
                .seguido(alvo)
                .build();
        
        seguidorRepository.save(novoSeguidor);
    }

    @Transactional
    public void deixarDeSeguirUsuario(String nodeIdAlvo, String nodeIdSolicitante) {
        Usuario alvo = usuarioRepository.findByNodeId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado."));
        Usuario solicitante = usuarioRepository.findByNodeId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário solicitante não encontrado."));

        Seguidor seguidor = seguidorRepository.findBySeguidorAndSeguido(solicitante, alvo)
                .orElseThrow(() -> new RegraNegocioException("Você não segue este usuário."));

        seguidorRepository.delete(seguidor);
    }

    @Transactional(readOnly = true)
    public List<PerfilResumidoDto> buscarPerfisPorIds(List<String> ids) {
        if (ids == null || ids.isEmpty()) {
            return List.of();
        }

        List<UUID> uuids = new ArrayList<>();
        List<String> nodeIds = new ArrayList<>();

        for (String str : ids) {
            if (str == null || str.isBlank()) continue;
            try {
                uuids.add(UUID.fromString(str));
            } catch (IllegalArgumentException e) {
                nodeIds.add(str);
            }
        }

        List<Usuario> usuarios = new ArrayList<>();
        if (!uuids.isEmpty()) {
            usuarios.addAll(usuarioRepository.findAllById(uuids));
        }

        for (String nodeId : nodeIds) {
            usuarioRepository.findByNodeId(nodeId).ifPresent(u -> {
                if (!usuarios.contains(u)) {
                    usuarios.add(u);
                }
            });
        }

        return usuarios.stream()
                .map(u -> new PerfilResumidoDto(
                        u.getId().toString(),
                        u.getNome(),
                        u.getNodeId(),
                        u.getAvatarUrl()
                ))
                .toList();
    }
}