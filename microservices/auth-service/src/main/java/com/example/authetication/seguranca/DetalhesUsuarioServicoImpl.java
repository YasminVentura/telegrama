package com.example.authetication.seguranca;

import com.example.authetication.modelo.Usuario;
import com.example.authetication.repositorio.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class DetalhesUsuarioServicoImpl implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String identificador) throws UsernameNotFoundException {
        if (identificador == null || identificador.isBlank()) {
            throw new UsernameNotFoundException("Identificador inválido.");
        }
        String limpo = identificador.trim();

        Optional<Usuario> usuario = usuarioRepository.findByEmailOrNodeId(limpo, limpo);

        if (usuario.isEmpty()) {
            String semArroba = limpo.startsWith("@") ? limpo.substring(1) : limpo;
            String comArroba = "@" + semArroba;
            usuario = usuarioRepository.findByNodeIdIgnoreCase(comArroba)
                    .or(() -> usuarioRepository.findByNodeIdIgnoreCase(semArroba));
        }

        return usuario.map(DetalhesUsuarioImpl::new)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado: " + identificador));
    }
}
