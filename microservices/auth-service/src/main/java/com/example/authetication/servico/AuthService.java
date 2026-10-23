package com.example.authetication.servico;

import com.example.authetication.dto.AutenticacaoResultado;
import com.example.authetication.dto.LoginRequisicaoDto;
import com.example.authetication.dto.UsuarioRespostaDto;
import com.example.authetication.modelo.Usuario;
import com.example.authetication.seguranca.DetalhesUsuarioImpl;
import com.example.authetication.seguranca.DetalhesUsuarioServicoImpl;
import com.example.authetication.seguranca.JwtUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final DetalhesUsuarioServicoImpl detalhesUsuarioServico;
    private final JwtUtils jwtUtils;
    private final StringRedisTemplate redisTemplate;

    public AutenticacaoResultado autenticar(LoginRequisicaoDto request) {
        // Autentica as credenciais com o AuthenticationManager configurado
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getIdentificador(),
                        request.getSenha()
                )
        );

        // Se passar, busca o UserDetails completo
        UserDetails userDetails = detalhesUsuarioServico.loadUserByUsername(request.getIdentificador());
        
        Map<String, Object> claimsExtras = new HashMap<>();
        Usuario usuario = null;
        if (userDetails instanceof DetalhesUsuarioImpl detalhes) {
            usuario = detalhes.getUsuario();
            claimsExtras.put("nome", usuario.getNome());
            claimsExtras.put("id", usuario.getId().toString());
            claimsExtras.put("nodeId", usuario.getNodeId());
        }

        // Gera o token JWT interno com os dados do usuário
        String jwt = jwtUtils.gerarToken(claimsExtras, userDetails);
        
        // Gera um identificador de sessão opaco e aleatório (UUID v4)
        String idSessao = UUID.randomUUID().toString();
        
        // Salva a sessão no Redis em memória com TTL de 24 horas
        redisTemplate.opsForValue().set("sessao:" + idSessao, jwt, Duration.ofHours(24));

        UsuarioRespostaDto usuarioDto = null;
        if (usuario != null) {
            usuarioDto = UsuarioRespostaDto.builder()
                    .id(usuario.getId())
                    .nome(usuario.getNome())
                    .nodeId(usuario.getNodeId())
                    .email(usuario.getEmail())
                    .bio(usuario.getBio())
                    .localizacao(usuario.getLocalizacao())
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
