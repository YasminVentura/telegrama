package com.example.authetication.servico;

import com.example.authetication.cliente.UserProfileClient;
import com.example.authetication.dto.AutenticacaoResultado;
import com.example.authetication.dto.CriarPerfilInternoRequisicaoDto;
import com.example.authetication.dto.LoginRequisicaoDto;
import com.example.authetication.dto.UsuarioRespostaDto;
import com.example.authetication.modelo.Usuario;
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

    private final AuthenticationManager authenticationManager;
    private final DetalhesUsuarioServicoImpl detalhesUsuarioServico;
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
                                .avatarUrl(UsuarioService.AVATAR_PADRAO)
                                .perfil(usuario.getPerfil())
                                .build()
                );
            } catch (Exception e) {
                log.warn("Aviso ao sincronizar perfil no login com user-profile-service: {}", e.getMessage());
            }
        }

        String jwt = jwtUtils.gerarToken(claimsExtras, userDetails);
        String idSessao = UUID.randomUUID().toString();
        redisTemplate.opsForValue().set("sessao:" + idSessao, jwt, Duration.ofHours(24));

        UsuarioRespostaDto usuarioDto = null;
        if (usuario != null) {
            usuarioDto = UsuarioRespostaDto.builder()
                    .id(usuario.getId())
                    .nome(usuario.getNome())
                    .nodeId(usuario.getNodeId())
                    .email(usuario.getEmail())
                    .perfil(usuario.getPerfil())
                    .idSessao(idSessao)
                    .build();
        }

        return new AutenticacaoResultado(idSessao, usuarioDto);
    }

    public void encerrarSessao(String idSessao) {
        if (idSessao != null && !idSessao.isBlank()) {
            redisTemplate.delete("sessao:" + idSessao);
        }
    }
}
