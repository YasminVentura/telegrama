package com.example.authetication.servico;

import com.example.authetication.cliente.UserProfileClient;
import com.example.authetication.dto.AutenticacaoResultado;
import com.example.authetication.dto.CriarPerfilInternoRequisicaoDto;
import com.example.authetication.dto.LoginRequisicaoDto;
import com.example.authetication.dto.UsuarioRespostaDto;
import com.example.authetication.excecao.RegraNegocioException;
import com.example.authetication.modelo.Usuario;
import com.example.authetication.repositorio.UsuarioRepository;
import com.example.authetication.seguranca.DetalhesUsuarioImpl;
import com.example.authetication.seguranca.DetalhesUsuarioServicoImpl;
import com.example.authetication.seguranca.JwtUtils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final Duration SESSAO_TTL = Duration.ofHours(24);
    private static final Duration REFRESH_TTL = Duration.ofDays(7);

    private final AuthenticationManager authenticationManager;
    private final DetalhesUsuarioServicoImpl detalhesUsuarioServico;
    private final UsuarioRepository usuarioRepository;
    private final JwtUtils jwtUtils;
    private final StringRedisTemplate redisTemplate;
    private final UserProfileClient userProfileClient;

    public AutenticacaoResultado autenticar(LoginRequisicaoDto request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getIdentificador(),
                        request.getSenha()
                )
        );

        UserDetails userDetails = detalhesUsuarioServico.loadUserByUsername(request.getIdentificador());
        return emitirSessaoERefreshToken(userDetails);
    }

    public AutenticacaoResultado renovarSessaoComRefreshToken(String refreshToken) {
        if (refreshToken == null || refreshToken.isBlank()) {
            throw new RegraNegocioException("Refresh token não informado.");
        }

        String chaveRefresh = "refresh:" + refreshToken.trim();
        String usuarioIdStr = redisTemplate.opsForValue().get(chaveRefresh);
        if (usuarioIdStr == null || usuarioIdStr.isBlank()) {
            throw new RegraNegocioException("Refresh token inválido ou expirado.");
        }

        Usuario usuario;
        try {
            usuario = usuarioRepository.findById(UUID.fromString(usuarioIdStr))
                    .orElseThrow(() -> new RegraNegocioException("Usuário associado ao refresh token não encontrado."));
        } catch (IllegalArgumentException e) {
            throw new RegraNegocioException("Identificador de usuário inválido no refresh token.");
        }

        redisTemplate.delete(chaveRefresh);

        UserDetails userDetails = new DetalhesUsuarioImpl(usuario);
        return emitirSessaoERefreshToken(userDetails);
    }

    private AutenticacaoResultado emitirSessaoERefreshToken(UserDetails userDetails) {
        Map<String, Object> claimsExtras = new HashMap<>();
        Usuario usuario = null;
        if (userDetails instanceof DetalhesUsuarioImpl detalhes) {
            usuario = detalhes.getUsuario();
            claimsExtras.put("nome", usuario.getNome());
            claimsExtras.put("id", usuario.getId().toString());
            claimsExtras.put("nodeId", usuario.getNodeId());
            claimsExtras.put("email", usuario.getEmail());
            claimsExtras.put("role", usuario.getPerfil() != null ? usuario.getPerfil().name() : "USER");

            try {
                userProfileClient.criarOuSincronizarPerfil(
                        CriarPerfilInternoRequisicaoDto.builder()
                                .id(usuario.getId())
                                .nome(usuario.getNome())
                                .nodeId(usuario.getNodeId())
                                .email(usuario.getEmail())
                                .avatarUrl(null)
                                .perfil(usuario.getPerfil())
                                .build()
                );
            } catch (Exception e) {
                log.warn("Aviso ao sincronizar perfil no login com user-profile-service: {}", e.getMessage());
            }
        }

        String jwt = jwtUtils.gerarToken(claimsExtras, userDetails);
        String idSessao = UUID.randomUUID().toString();
        String refreshToken = UUID.randomUUID().toString();

        redisTemplate.opsForValue().set("sessao:" + idSessao, jwt, SESSAO_TTL);
        if (usuario != null) {
            redisTemplate.opsForValue().set("refresh:" + refreshToken, usuario.getId().toString(), REFRESH_TTL);
        }

        UsuarioRespostaDto usuarioDto = null;
        if (usuario != null) {
            usuarioDto = UsuarioRespostaDto.builder()
                    .id(usuario.getId())
                    .nome(usuario.getNome())
                    .nodeId(usuario.getNodeId())
                    .email(usuario.getEmail())
                    .perfil(usuario.getPerfil())
                    .idSessao(idSessao)
                    .refreshToken(refreshToken)
                    .build();
        }

        return new AutenticacaoResultado(idSessao, refreshToken, usuarioDto);
    }

    public void encerrarSessao(String idSessao, String refreshToken) {
        if (idSessao != null && !idSessao.isBlank()) {
            redisTemplate.delete("sessao:" + idSessao.trim());
        }
        if (refreshToken != null && !refreshToken.isBlank()) {
            redisTemplate.delete("refresh:" + refreshToken.trim());
        }
    }
}
