package com.example.authetication.seguranca;

import com.example.authetication.modelo.Usuario;
import com.example.authetication.repositorio.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DetalhesUsuarioServicoImpl implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;

    @Override
    public UserDetails loadUserByUsername(String identificador) throws UsernameNotFoundException {
        // Busca tanto por email quanto por node_id, como solicitado
        Usuario usuario = usuarioRepository.findByEmailOrNodeId(identificador, identificador)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado: " + identificador));

        return new DetalhesUsuarioImpl(usuario);
    }
}
