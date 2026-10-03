package com.example.authetication.servico;

import com.example.authetication.dto.PerfilRespostaDto;
import com.example.authetication.dto.RegistroRequisicaoDto;
import com.example.authetication.excecao.RegraNegocioException;
import com.example.authetication.mapper.UsuarioMapper;
import com.example.authetication.modelo.Seguidor;
import com.example.authetication.modelo.Usuario;
import com.example.authetication.repositorio.SeguidorRepository;
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
        
        usuarioRepository.save(usuario);
    }

    @Transactional(readOnly = true)
    public PerfilRespostaDto buscarPerfil(String nodeId) {
        Usuario usuario = usuarioRepository.findByNodeId(nodeId)
                .orElseThrow(() -> new RegraNegocioException("Usuário não encontrado."));

        PerfilRespostaDto perfilDto = usuarioMapper.paraPerfilDto(usuario);
        
        long seguidores = seguidorRepository.countBySeguido(usuario);
        long seguindo = seguidorRepository.countBySeguidor(usuario);
        
        perfilDto.setQuantidadeSeguidores(seguidores);
        perfilDto.setQuantidadeSeguindo(seguindo);
        
        return perfilDto;
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
}
