package com.example.authetication.servico;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
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

    public static final String AVATAR_PADRAO = "lib/assets/images/avatars/avatar_1.webp";

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
        if (usuario.getAvatarUrl() == null || usuario.getAvatarUrl().isBlank()) {
            usuario.setAvatarUrl(AVATAR_PADRAO);
        }
        
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
                .avatarUrl(usuario.getAvatarUrl())
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
        Usuario usuario = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado: " + nodeIdAlvo));

        UsuarioPreferencias preferencias = usuario.getPreferencias();
        if (preferencias == null) {
            preferencias = obterOuCriarPreferencias(usuario);
        }

        String avatarEfetivo = resolverAvatar(usuario, preferencias);
        if (preferencias.getAvatarUrl() == null || preferencias.getAvatarUrl().isBlank()) {
            preferencias.setAvatarUrl(avatarEfetivo);
        }
        if (usuario.getAvatarUrl() == null || usuario.getAvatarUrl().isBlank()) {
            usuario.setAvatarUrl(avatarEfetivo);
        }

        PerfilRespostaDto perfilDto = usuarioMapper.paraPerfilDto(usuario);
        perfilDto.setAvatarUrl(avatarEfetivo);
        
        long seguidores = seguidorRepository.countBySeguido(usuario);
        long seguindo = seguidorRepository.countBySeguidor(usuario);
        
        perfilDto.setQuantidadeSeguidores(seguidores);
        perfilDto.setQuantidadeSeguindo(seguindo);

        boolean isMe = false;
        if (nodeIdSolicitante != null) {
            String cleanSolicitante = nodeIdSolicitante.replaceAll("@", "");
            String cleanAlvo = usuario.getNodeId().replaceAll("@", "");
            isMe = cleanSolicitante.equalsIgnoreCase(cleanAlvo) 
                    || nodeIdSolicitante.equalsIgnoreCase(usuario.getEmail())
                    || nodeIdSolicitante.equals(usuario.getId().toString());
        }
        perfilDto.setMe(isMe);

        if (!isMe && nodeIdSolicitante != null) {
            encontrarUsuarioPorNodeIdOuId(nodeIdSolicitante).ifPresent(solicitante -> {
                boolean segue = seguidorRepository.existsBySeguidorAndSeguido(solicitante, usuario);
                perfilDto.setSeguindo(segue);
            });
        }

        if (isMe) {
            UsuarioPreferenciasDto prefsDto = usuarioMapper.paraPreferenciasDto(preferencias);
            if (prefsDto != null) {
                prefsDto.setAvatarUrl(avatarEfetivo);
            }
            perfilDto.setPreferencias(prefsDto);
        }
        
        return perfilDto;
    }

    @Transactional
    public UsuarioPreferenciasDto buscarPreferencias(String nodeId) {
        Usuario usuario = encontrarUsuarioPorNodeIdOuId(nodeId)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado: " + nodeId));

        UsuarioPreferencias preferencias = usuario.getPreferencias();
        if (preferencias == null) {
            preferencias = obterOuCriarPreferencias(usuario);
        }
        String avatarEfetivo = resolverAvatar(usuario, preferencias);
        if (preferencias.getAvatarUrl() == null || preferencias.getAvatarUrl().isBlank()) {
            preferencias.setAvatarUrl(avatarEfetivo);
        }

        UsuarioPreferenciasDto prefsDto = usuarioMapper.paraPreferenciasDto(preferencias);
        if (prefsDto != null) {
            prefsDto.setAvatarUrl(avatarEfetivo);
        }
        return prefsDto;
    }

    @Transactional
    public PerfilRespostaDto atualizarPerfil(String nodeIdSolicitante, AtualizarPerfilRequisicaoDto dto) {
        Usuario usuario = encontrarUsuarioPorNodeIdOuId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado: " + nodeIdSolicitante));

        if (dto.getNome() != null && !dto.getNome().isBlank()) {
            usuario.setNome(dto.getNome().trim());
        }
        if (dto.getBio() != null) {
            usuario.setBio(dto.getBio().trim());
        }
        if (dto.getLocalizacao() != null) {
            usuario.setLocalizacao(dto.getLocalizacao().trim());
        }

        UsuarioPreferencias prefs = usuario.getPreferencias();
        if (prefs == null) {
            prefs = obterOuCriarPreferencias(usuario);
        }

        if (dto.getAvatarUrl() != null && !dto.getAvatarUrl().isBlank()) {
            String novoAvatar = dto.getAvatarUrl().trim();
            usuario.setAvatarUrl(novoAvatar);
            prefs.setAvatarUrl(novoAvatar);
        }

        if (dto.getPreferencias() != null) {
            atualizarCamposPreferencias(prefs, dto.getPreferencias());
            if (dto.getPreferencias().getAvatarUrl() != null && !dto.getPreferencias().getAvatarUrl().isBlank()) {
                usuario.setAvatarUrl(dto.getPreferencias().getAvatarUrl().trim());
            }
        }
        usuarioPreferenciasRepository.save(prefs);
        usuario.setPreferencias(prefs);

        Usuario salvo = usuarioRepository.save(usuario);
        String avatarEfetivo = resolverAvatar(salvo, salvo.getPreferencias());
        PerfilRespostaDto resposta = usuarioMapper.paraPerfilDto(salvo);
        resposta.setAvatarUrl(avatarEfetivo);
        
        long seguidores = seguidorRepository.countBySeguido(salvo);
        long seguindo = seguidorRepository.countBySeguidor(salvo);
        resposta.setQuantidadeSeguidores(seguidores);
        resposta.setQuantidadeSeguindo(seguindo);
        resposta.setMe(true);
        if (salvo.getPreferencias() != null) {
            UsuarioPreferenciasDto prefsDto = usuarioMapper.paraPreferenciasDto(salvo.getPreferencias());
            if (prefsDto != null) {
                prefsDto.setAvatarUrl(avatarEfetivo);
            }
            resposta.setPreferencias(prefsDto);
        }

        return resposta;
    }

    @Transactional
    public UsuarioPreferenciasDto atualizarPreferencias(String nodeIdSolicitante, UsuarioPreferenciasDto dto) {
        Usuario usuario = encontrarUsuarioPorNodeIdOuId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado: " + nodeIdSolicitante));

        UsuarioPreferencias prefs = usuario.getPreferencias();
        if (prefs == null) {
            prefs = obterOuCriarPreferencias(usuario);
        }

        atualizarCamposPreferencias(prefs, dto);
        if (dto.getAvatarUrl() != null && !dto.getAvatarUrl().isBlank()) {
            String novoAvatar = dto.getAvatarUrl().trim();
            prefs.setAvatarUrl(novoAvatar);
            usuario.setAvatarUrl(novoAvatar);
            usuarioRepository.save(usuario);
        }
        UsuarioPreferencias salva = usuarioPreferenciasRepository.save(prefs);
        UsuarioPreferenciasDto respostaDto = usuarioMapper.paraPreferenciasDto(salva);
        if (respostaDto != null) {
            respostaDto.setAvatarUrl(resolverAvatar(usuario, salva));
        }
        return respostaDto;
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
        if (dto.getAvatarUrl() != null && !dto.getAvatarUrl().isBlank()) {
            prefs.setAvatarUrl(dto.getAvatarUrl().trim());
        }
    }

    private String resolverAvatar(Usuario usuario, UsuarioPreferencias prefs) {
        if (prefs != null && prefs.getAvatarUrl() != null && !prefs.getAvatarUrl().isBlank()) {
            return prefs.getAvatarUrl();
        }
        if (usuario.getAvatarUrl() != null && !usuario.getAvatarUrl().isBlank()) {
            return usuario.getAvatarUrl();
        }
        return AVATAR_PADRAO;
    }

    private UsuarioPreferencias obterOuCriarPreferencias(Usuario usuario) {
        return usuarioPreferenciasRepository.findByUsuario(usuario)
                .orElseGet(() -> {
                    String avatarInicial = (usuario.getAvatarUrl() != null && !usuario.getAvatarUrl().isBlank())
                            ? usuario.getAvatarUrl()
                            : AVATAR_PADRAO;
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
                            .avatarUrl(avatarInicial)
                            .build();
                    return usuarioPreferenciasRepository.save(nova);
                });
    }

    @Transactional
    public void excluirConta(String nodeIdAlvo, String nodeIdSolicitante) {
        Usuario alvo = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado: " + nodeIdAlvo));

        Usuario solicitante = encontrarUsuarioPorNodeIdOuId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário solicitante não encontrado: " + nodeIdSolicitante));

        if (!alvo.getId().equals(solicitante.getId()) && solicitante.getPerfil() != com.example.authetication.modelo.Role.ADMIN) {
            throw new RegraNegocioException("Sem permissão para excluir esta conta. Apenas o proprietário ou um administrador podem realizar esta ação.");
        }

        usuarioRepository.delete(alvo);
    }

    @Transactional
    public void seguirUsuario(String nodeIdAlvo, String nodeIdSolicitante) {
        Usuario alvo = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado: " + nodeIdAlvo));
        Usuario solicitante = encontrarUsuarioPorNodeIdOuId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário solicitante não encontrado: " + nodeIdSolicitante));

        if (alvo.getId().equals(solicitante.getId())) {
            throw new RegraNegocioException("Você não pode seguir a si mesmo.");
        }

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
        Usuario alvo = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado: " + nodeIdAlvo));
        Usuario solicitante = encontrarUsuarioPorNodeIdOuId(nodeIdSolicitante)
                .orElseThrow(() -> new RegraNegocioException("Usuário solicitante não encontrado: " + nodeIdSolicitante));

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
            String limpo = str.trim();
            try {
                uuids.add(UUID.fromString(limpo));
            } catch (IllegalArgumentException e) {
                nodeIds.add(limpo);
                if (limpo.startsWith("@")) {
                    nodeIds.add(limpo.substring(1));
                }
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
                        resolverAvatar(u, u.getPreferencias())
                ))
                .toList();
    }

    @Transactional(readOnly = true)
    public List<PerfilResumidoDto> buscarUsuariosPorTermo(String termo) {
        if (termo == null || termo.isBlank()) {
            return List.of();
        }
        String busca = termo.trim();
        if (busca.startsWith("telegrama.zone/")) {
            busca = busca.replace("telegrama.zone/", "");
        }
        if (busca.startsWith("@")) {
            busca = busca.substring(1);
        }
        if (busca.isBlank()) {
            return List.of();
        }

        List<Usuario> usuarios = usuarioRepository.findByNomeContainingIgnoreCaseOrNodeIdContainingIgnoreCase(busca, busca);
        return usuarios.stream()
                .map(u -> new PerfilResumidoDto(
                        u.getId().toString(),
                        u.getNome(),
                        u.getNodeId(),
                        resolverAvatar(u, u.getPreferencias())
                ))
                .toList();
    }

    public Optional<Usuario> encontrarUsuarioPorNodeIdOuId(String identificador) {
        if (identificador == null || identificador.isBlank()) {
            return Optional.empty();
        }
        String limpo = identificador.trim();

        // 1. Tenta buscar por UUID se for formato UUID válido
        try {
            UUID uuid = UUID.fromString(limpo);
            Optional<Usuario> porUuid = usuarioRepository.findById(uuid);
            if (porUuid.isPresent()) {
                return porUuid;
            }
        } catch (IllegalArgumentException ignored) {
        }

        // 2. Tenta exatamente como veio (ex: "yasmin_v" ou "@yasmin_v")
        Optional<Usuario> usuario = usuarioRepository.findByNodeId(limpo);
        if (usuario.isPresent()) {
            return usuario;
        }

        // 3. Tenta alternando o prefixo '@'
        if (limpo.startsWith("@")) {
            usuario = usuarioRepository.findByNodeId(limpo.substring(1));
        } else {
            usuario = usuarioRepository.findByNodeId("@" + limpo);
        }
        if (usuario.isPresent()) {
            return usuario;
        }

        // 4. Fallback por e-mail
        return usuarioRepository.findByEmail(limpo);
    }
}