package com.example.profile.servico;

import com.example.profile.cliente.AuthClient;
import com.example.profile.cliente.PostClient;
import com.example.profile.dto.AtualizarPerfilRequisicaoDto;
import com.example.profile.dto.CriarPerfilInternoRequisicaoDto;
import com.example.profile.dto.PerfilRespostaDto;
import com.example.profile.dto.PerfilResumidoDto;
import com.example.profile.dto.UsuarioPreferenciasDto;
import com.example.profile.excecao.RegraNegocioException;
import com.example.profile.mapper.PerfilUsuarioMapper;
import com.example.profile.modelo.PerfilUsuario;
import com.example.profile.modelo.Role;
import com.example.profile.modelo.Seguidor;
import com.example.profile.modelo.TemaVisual;
import com.example.profile.modelo.UsuarioPreferencias;
import com.example.profile.repositorio.PerfilUsuarioRepository;
import com.example.profile.repositorio.SeguidorRepository;
import com.example.profile.repositorio.UsuarioPreferenciasRepository;
import com.example.profile.seguranca.UsuarioAutenticado;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class PerfilUsuarioService {

    public static final String AVATAR_PADRAO = "lib/assets/images/avatars/avatar_1.webp";
    public static final String BANNER_COR_PADRAO = "#2E4F3E";

    private final PerfilUsuarioRepository perfilUsuarioRepository;
    private final SeguidorRepository seguidorRepository;
    private final UsuarioPreferenciasRepository usuarioPreferenciasRepository;
    private final PerfilUsuarioMapper perfilUsuarioMapper;
    private final AuthClient authClient;
    private final PostClient postClient;

    @Transactional
    public PerfilRespostaDto criarOuSincronizarPerfilInterno(CriarPerfilInternoRequisicaoDto dto) {
        Optional<PerfilUsuario> existente = encontrarUsuarioPorNodeIdOuId(
                dto.getId() != null ? dto.getId().toString() : dto.getNodeId()
        );
        if (existente.isEmpty() && dto.getNodeId() != null) {
            existente = encontrarUsuarioPorNodeIdOuId(dto.getNodeId());
        }

        if (existente.isPresent()) {
            PerfilUsuario atual = existente.get();
            boolean alterou = false;
            if (dto.getPerfil() != null && atual.getPerfil() != dto.getPerfil()) {
                atual.setPerfil(dto.getPerfil());
                alterou = true;
            }
            if (dto.getAvatarUrl() != null && !dto.getAvatarUrl().isBlank()) {
                atual.setAvatarUrl(dto.getAvatarUrl().trim());
                if (atual.getPreferencias() != null) {
                    atual.getPreferencias().setAvatarUrl(dto.getAvatarUrl().trim());
                }
                alterou = true;
            }
            if (atual.getBannerColor() == null || atual.getBannerColor().isBlank()) {
                atual.setBannerColor(BANNER_COR_PADRAO);
                alterou = true;
            }
            if (alterou) {
                atual = perfilUsuarioRepository.save(atual);
            }
            return perfilUsuarioMapper.paraPerfilDto(atual);
        }

        String avatar = (dto.getAvatarUrl() != null && !dto.getAvatarUrl().isBlank())
                ? dto.getAvatarUrl()
                : AVATAR_PADRAO;

        PerfilUsuario novo = PerfilUsuario.builder()
                .id(dto.getId() != null ? dto.getId() : UUID.randomUUID())
                .nome(dto.getNome())
                .nodeId(dto.getNodeId())
                .email(dto.getEmail())
                .avatarUrl(avatar)
                .bannerColor(BANNER_COR_PADRAO)
                .perfil(dto.getPerfil() != null ? dto.getPerfil() : Role.USER)
                .build();

        UsuarioPreferencias preferenciasPadrao = UsuarioPreferencias.builder()
                .usuario(novo)
                .privateFrequencyMode(false)
                .directTransmissions(true)
                .broadcastNodeActivity(true)
                .pushTransmissions(true)
                .acousticEchos(true)
                .zoneBroadcastAlerts(false)
                .twoFactorAuth(false)
                .theme(TemaVisual.RETRO_GREEN)
                .avatarUrl(avatar)
                .bannerColor(BANNER_COR_PADRAO)
                .build();
        novo.setPreferencias(preferenciasPadrao);

        PerfilUsuario salvo = perfilUsuarioRepository.save(novo);
        return perfilUsuarioMapper.paraPerfilDto(salvo);
    }

    @Transactional
    public PerfilRespostaDto buscarMeuPerfil(UsuarioAutenticado solicitanteAuth) {
        if (solicitanteAuth == null || solicitanteAuth.getNodeId() == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }
        garantirPerfilParaAutenticado(solicitanteAuth);
        return buscarPerfil(solicitanteAuth.getNodeId(), solicitanteAuth.getNodeId());
    }

    @Transactional
    public PerfilRespostaDto buscarPerfil(String nodeIdAlvo, String nodeIdSolicitante) {
        PerfilUsuario usuario = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
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

        String bannerEfetivo = resolverBannerColor(usuario, preferencias);
        if (preferencias.getBannerColor() == null || preferencias.getBannerColor().isBlank()) {
            preferencias.setBannerColor(bannerEfetivo);
        }
        if (usuario.getBannerColor() == null || usuario.getBannerColor().isBlank()) {
            usuario.setBannerColor(bannerEfetivo);
        }

        PerfilRespostaDto perfilDto = perfilUsuarioMapper.paraPerfilDto(usuario);
        perfilDto.setAvatarUrl(avatarEfetivo);
        perfilDto.setBannerColor(bannerEfetivo);

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
            UsuarioPreferenciasDto prefsDto = perfilUsuarioMapper.paraPreferenciasDto(preferencias);
            if (prefsDto != null) {
                prefsDto.setAvatarUrl(avatarEfetivo);
                prefsDto.setBannerColor(bannerEfetivo);
            }
            perfilDto.setPreferencias(prefsDto);
        }

        return perfilDto;
    }

    @Transactional
    public UsuarioPreferenciasDto buscarPreferencias(UsuarioAutenticado solicitanteAuth) {
        PerfilUsuario usuario = garantirPerfilParaAutenticado(solicitanteAuth);

        UsuarioPreferencias preferencias = usuario.getPreferencias();
        if (preferencias == null) {
            preferencias = obterOuCriarPreferencias(usuario);
        }
        String avatarEfetivo = resolverAvatar(usuario, preferencias);
        if (preferencias.getAvatarUrl() == null || preferencias.getAvatarUrl().isBlank()) {
            preferencias.setAvatarUrl(avatarEfetivo);
        }
        String bannerEfetivo = resolverBannerColor(usuario, preferencias);
        if (preferencias.getBannerColor() == null || preferencias.getBannerColor().isBlank()) {
            preferencias.setBannerColor(bannerEfetivo);
        }

        UsuarioPreferenciasDto prefsDto = perfilUsuarioMapper.paraPreferenciasDto(preferencias);
        if (prefsDto != null) {
            prefsDto.setAvatarUrl(avatarEfetivo);
            prefsDto.setBannerColor(bannerEfetivo);
        }
        return prefsDto;
    }

    @Transactional
    public PerfilRespostaDto atualizarPerfil(UsuarioAutenticado solicitanteAuth, AtualizarPerfilRequisicaoDto dto) {
        PerfilUsuario usuario = garantirPerfilParaAutenticado(solicitanteAuth);

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

        if (dto.getBannerColor() != null && !dto.getBannerColor().isBlank()) {
            String novaCor = dto.getBannerColor().trim();
            usuario.setBannerColor(novaCor);
            prefs.setBannerColor(novaCor);
        }

        if (dto.getPreferencias() != null) {
            atualizarCamposPreferencias(prefs, dto.getPreferencias());
            if (dto.getPreferencias().getAvatarUrl() != null && !dto.getPreferencias().getAvatarUrl().isBlank()) {
                usuario.setAvatarUrl(dto.getPreferencias().getAvatarUrl().trim());
            }
            if (dto.getPreferencias().getBannerColor() != null && !dto.getPreferencias().getBannerColor().isBlank()) {
                usuario.setBannerColor(dto.getPreferencias().getBannerColor().trim());
            }
        }
        usuarioPreferenciasRepository.save(prefs);
        usuario.setPreferencias(prefs);

        PerfilUsuario salvo = perfilUsuarioRepository.save(usuario);
        String avatarEfetivo = resolverAvatar(salvo, salvo.getPreferencias());
        String bannerEfetivo = resolverBannerColor(salvo, salvo.getPreferencias());
        PerfilRespostaDto resposta = perfilUsuarioMapper.paraPerfilDto(salvo);
        resposta.setAvatarUrl(avatarEfetivo);
        resposta.setBannerColor(bannerEfetivo);

        long seguidores = seguidorRepository.countBySeguido(salvo);
        long seguindo = seguidorRepository.countBySeguidor(salvo);
        resposta.setQuantidadeSeguidores(seguidores);
        resposta.setQuantidadeSeguindo(seguindo);
        resposta.setMe(true);
        if (salvo.getPreferencias() != null) {
            UsuarioPreferenciasDto prefsDto = perfilUsuarioMapper.paraPreferenciasDto(salvo.getPreferencias());
            if (prefsDto != null) {
                prefsDto.setAvatarUrl(avatarEfetivo);
                prefsDto.setBannerColor(bannerEfetivo);
            }
            resposta.setPreferencias(prefsDto);
        }

        return resposta;
    }

    @Transactional
    public UsuarioPreferenciasDto atualizarPreferencias(UsuarioAutenticado solicitanteAuth, UsuarioPreferenciasDto dto) {
        PerfilUsuario usuario = garantirPerfilParaAutenticado(solicitanteAuth);

        UsuarioPreferencias prefs = usuario.getPreferencias();
        if (prefs == null) {
            prefs = obterOuCriarPreferencias(usuario);
        }

        atualizarCamposPreferencias(prefs, dto);
        boolean alterouUsuario = false;
        if (dto.getAvatarUrl() != null && !dto.getAvatarUrl().isBlank()) {
            String novoAvatar = dto.getAvatarUrl().trim();
            prefs.setAvatarUrl(novoAvatar);
            usuario.setAvatarUrl(novoAvatar);
            alterouUsuario = true;
        }
        if (dto.getBannerColor() != null && !dto.getBannerColor().isBlank()) {
            String novaCor = dto.getBannerColor().trim();
            prefs.setBannerColor(novaCor);
            usuario.setBannerColor(novaCor);
            alterouUsuario = true;
        }
        if (alterouUsuario) {
            perfilUsuarioRepository.save(usuario);
        }
        UsuarioPreferencias salva = usuarioPreferenciasRepository.save(prefs);
        UsuarioPreferenciasDto respostaDto = perfilUsuarioMapper.paraPreferenciasDto(salva);
        if (respostaDto != null) {
            respostaDto.setAvatarUrl(resolverAvatar(usuario, salva));
            respostaDto.setBannerColor(resolverBannerColor(usuario, salva));
        }
        return respostaDto;
    }

    @Transactional
    public void excluirConta(String nodeIdAlvo, UsuarioAutenticado solicitanteAuth) {
        if (solicitanteAuth == null || solicitanteAuth.getNodeId() == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }

        PerfilUsuario alvo = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado: " + nodeIdAlvo));

        PerfilUsuario solicitante = garantirPerfilParaAutenticado(solicitanteAuth);

        boolean ehProprietario = alvo.getId().equals(solicitante.getId())
                || alvo.getNodeId().replaceAll("@", "").equalsIgnoreCase(solicitante.getNodeId().replaceAll("@", ""));
        boolean ehAdmin = solicitanteAuth.isAdmin() || solicitante.getPerfil() == Role.ADMIN;

        if (!ehProprietario && !ehAdmin) {
            throw new RegraNegocioException("Sem permissão para excluir esta conta. Apenas o proprietário ou um administrador podem realizar esta ação.");
        }

        String alvoNodeId = alvo.getNodeId();
        String alvoId = alvo.getId().toString();

        // 1. Remove vínculos de seguidores antes de apagar o perfil
        seguidorRepository.deleteBySeguidorOrSeguido(alvo, alvo);
        perfilUsuarioRepository.delete(alvo);

        // 2. Aciona o post-service para remover postagens do usuário excluído
        try {
            postClient.excluirPostagensPorAutor(alvoNodeId);
        } catch (Exception e) {
            log.warn("Falha ao excluir postagens em cascata para {}: {}", alvoNodeId, e.getMessage());
        }

        // 3. Aciona o auth-service para remover credenciais e sessões
        try {
            authClient.excluirCredencialInterna(alvoId);
        } catch (Exception e) {
            log.warn("Falha ao excluir credencial em cascata no auth-service para {}: {}", alvoId, e.getMessage());
        }
    }

    @Transactional
    public void seguirUsuario(String nodeIdAlvo, UsuarioAutenticado solicitanteAuth) {
        PerfilUsuario alvo = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado: " + nodeIdAlvo));
        PerfilUsuario solicitante = garantirPerfilParaAutenticado(solicitanteAuth);

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
    public void deixarDeSeguirUsuario(String nodeIdAlvo, UsuarioAutenticado solicitanteAuth) {
        PerfilUsuario alvo = encontrarUsuarioPorNodeIdOuId(nodeIdAlvo)
                .orElseThrow(() -> new RegraNegocioException("Usuário alvo não encontrado: " + nodeIdAlvo));
        PerfilUsuario solicitante = garantirPerfilParaAutenticado(solicitanteAuth);

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
                } else {
                    nodeIds.add("@" + limpo);
                }
            }
        }

        List<PerfilUsuario> usuarios = new ArrayList<>();
        if (!uuids.isEmpty()) {
            usuarios.addAll(perfilUsuarioRepository.findAllById(uuids));
        }

        for (String nodeId : nodeIds) {
            perfilUsuarioRepository.findByNodeIdIgnoreCase(nodeId).ifPresent(u -> {
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

        List<PerfilUsuario> usuarios = perfilUsuarioRepository.findByNomeContainingIgnoreCaseOrNodeIdContainingIgnoreCase(busca, busca);
        return usuarios.stream()
                .map(u -> new PerfilResumidoDto(
                        u.getId().toString(),
                        u.getNome(),
                        u.getNodeId(),
                        resolverAvatar(u, u.getPreferencias())
                ))
                .toList();
    }

    public Optional<PerfilUsuario> encontrarUsuarioPorNodeIdOuId(String identificador) {
        if (identificador == null || identificador.isBlank()) {
            return Optional.empty();
        }
        String limpo = identificador.trim();

        try {
            UUID uuid = UUID.fromString(limpo);
            Optional<PerfilUsuario> porUuid = perfilUsuarioRepository.findById(uuid);
            if (porUuid.isPresent()) {
                return porUuid;
            }
        } catch (IllegalArgumentException ignored) {
        }

        Optional<PerfilUsuario> usuario = perfilUsuarioRepository.findByNodeIdIgnoreCase(limpo);
        if (usuario.isPresent()) {
            return usuario;
        }

        if (limpo.startsWith("@")) {
            usuario = perfilUsuarioRepository.findByNodeIdIgnoreCase(limpo.substring(1));
        } else {
            usuario = perfilUsuarioRepository.findByNodeIdIgnoreCase("@" + limpo);
        }
        if (usuario.isPresent()) {
            return usuario;
        }

        return perfilUsuarioRepository.findByEmail(limpo);
    }

    private PerfilUsuario garantirPerfilParaAutenticado(UsuarioAutenticado auth) {
        if (auth == null || auth.getNodeId() == null) {
            throw new RegraNegocioException("Usuário não autenticado.");
        }

        Optional<PerfilUsuario> opt = encontrarUsuarioPorNodeIdOuId(auth.getNodeId());
        if (opt.isEmpty() && auth.getId() != null) {
            opt = encontrarUsuarioPorNodeIdOuId(auth.getId());
        }

        if (opt.isPresent()) {
            PerfilUsuario existente = opt.get();
            Role roleToken = auth.isAdmin() ? Role.ADMIN : Role.USER;
            if (existente.getPerfil() != roleToken) {
                existente.setPerfil(roleToken);
                existente = perfilUsuarioRepository.save(existente);
            }
            return existente;
        }

        // Auto-provisiona o perfil caso o usuário já existisse no auth-service antes da separação de bancos
        UUID uuid = null;
        if (auth.getId() != null) {
            try {
                uuid = UUID.fromString(auth.getId());
            } catch (IllegalArgumentException ignored) {
            }
        }
        if (uuid == null) {
            uuid = UUID.randomUUID();
        }

        String nodeIdFormatado = auth.getNodeId().startsWith("@") ? auth.getNodeId() : "@" + auth.getNodeId();
        String emailFallback = (auth.getEmail() != null && !auth.getEmail().isBlank())
                ? auth.getEmail()
                : nodeIdFormatado.substring(1) + "@telegrama.zone";

        PerfilUsuario novo = PerfilUsuario.builder()
                .id(uuid)
                .nome(auth.getNome() != null ? auth.getNome() : nodeIdFormatado)
                .nodeId(nodeIdFormatado)
                .email(emailFallback)
                .avatarUrl(AVATAR_PADRAO)
                .bannerColor(BANNER_COR_PADRAO)
                .perfil(auth.isAdmin() ? Role.ADMIN : Role.USER)
                .build();

        UsuarioPreferencias prefs = UsuarioPreferencias.builder()
                .usuario(novo)
                .theme(TemaVisual.RETRO_GREEN)
                .avatarUrl(AVATAR_PADRAO)
                .bannerColor(BANNER_COR_PADRAO)
                .build();
        novo.setPreferencias(prefs);

        return perfilUsuarioRepository.save(novo);
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
        if (dto.getBannerColor() != null && !dto.getBannerColor().isBlank()) {
            prefs.setBannerColor(dto.getBannerColor().trim());
        }
    }

    private String resolverAvatar(PerfilUsuario usuario, UsuarioPreferencias prefs) {
        if (prefs != null && prefs.getAvatarUrl() != null && !prefs.getAvatarUrl().isBlank()) {
            return prefs.getAvatarUrl();
        }
        if (usuario.getAvatarUrl() != null && !usuario.getAvatarUrl().isBlank()) {
            return usuario.getAvatarUrl();
        }
        return AVATAR_PADRAO;
    }

    private String resolverBannerColor(PerfilUsuario usuario, UsuarioPreferencias prefs) {
        if (prefs != null && prefs.getBannerColor() != null && !prefs.getBannerColor().isBlank()) {
            return prefs.getBannerColor();
        }
        if (usuario.getBannerColor() != null && !usuario.getBannerColor().isBlank()) {
            return usuario.getBannerColor();
        }
        return BANNER_COR_PADRAO;
    }

    private UsuarioPreferencias obterOuCriarPreferencias(PerfilUsuario usuario) {
        return usuarioPreferenciasRepository.findByUsuario(usuario)
                .orElseGet(() -> {
                    String avatarInicial = (usuario.getAvatarUrl() != null && !usuario.getAvatarUrl().isBlank())
                            ? usuario.getAvatarUrl()
                            : AVATAR_PADRAO;
                    String bannerInicial = (usuario.getBannerColor() != null && !usuario.getBannerColor().isBlank())
                            ? usuario.getBannerColor()
                            : BANNER_COR_PADRAO;
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
                            .bannerColor(bannerInicial)
                            .build();
                    return usuarioPreferenciasRepository.save(nova);
                });
    }
}
