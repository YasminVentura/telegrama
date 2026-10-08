package com.example.authetication.servico;

import com.example.authetication.dto.LoginRequisicaoDto;
import com.example.authetication.dto.TokenRespostaDto;
import com.example.authetication.seguranca.DetalhesUsuarioServicoImpl;
import com.example.authetication.seguranca.JwtUtils;
import com.example.authetication.seguranca.UtilidadesCriptografia;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AuthenticationManager authenticationManager;
    private final DetalhesUsuarioServicoImpl detalhesUsuarioServico;
    private final JwtUtils jwtUtils;

    public String autenticar(LoginRequisicaoDto request) {
        // Autentica as credenciais com o AuthenticationManager configurado
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getIdentificador(),
                        request.getSenha()
                )
        );

        // Se passar, busca o UserDetails completo
        UserDetails userDetails = detalhesUsuarioServico.loadUserByUsername(request.getIdentificador());
        
        // Gera o token
        String jwt = jwtUtils.gerarToken(userDetails);
        
        // Retorna o idSessao criptografado
        return UtilidadesCriptografia.criptografar(jwt);
    }
}
