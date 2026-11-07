package com.example.post.servico;

import com.example.post.cliente.AuthClient;
import com.example.post.dto.CriarPostagemRequisicaoDto;
import com.example.post.dto.PerfilResumidoDto;
import com.example.post.dto.PostagemRespostaDto;
import com.example.post.excecao.AcessoNegadoException;
import com.example.post.excecao.PostagemNaoEncontradaException;
import com.example.post.modelo.Postagem;
import com.example.post.repositorio.PostagemRepository;
import com.example.post.seguranca.UsuarioAutenticado;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class PostagemService {

    private final PostagemRepository postagemRepository;
    private final AuthClient authClient;

    public PostagemRespostaDto criarPostagem(CriarPostagemRequisicaoDto requisicao, UsuarioAutenticado autor) {
        LocalDateTime agora = LocalDateTime.now();

        Postagem postagem = Postagem.builder()
                .autorId(autor.getId())
                .autorNodeId(autor.getNodeId())
                .autorNome(autor.getNome())
                .autorAvatarUrl(null)
                .conteudo(requisicao.getContent())
                .curtidas(new HashSet<>())
                .quantidadeCurtidas(0)
                .quantidadeComentarios(0)
                .criadoEm(agora)
                .atualizadoEm(agora)
                .build();

        Postagem salva = postagemRepository.save(postagem);
        List<String> identificadores = extrairIdentificadores(List.of(salva));
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);
        return mapearParaRespostaDto(salva, autor, obterPerfilDoMap(salva, perfisMap));
    }

    public List<PostagemRespostaDto> listarPostagens(int pagina, int limite, UsuarioAutenticado usuarioLogado) {
        int paginaIndex = Math.max(0, pagina - 1);
        int limiteValido = Math.max(1, limite);
        Pageable pageable = PageRequest.of(paginaIndex, limiteValido);

        List<Postagem> postagens = postagemRepository.findAllByOrderByCriadoEmDesc(pageable).getContent();

        List<String> identificadores = extrairIdentificadores(postagens);
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return postagens.stream()
                .map(p -> mapearParaRespostaDto(p, usuarioLogado, obterPerfilDoMap(p, perfisMap)))
                .toList();
    }

    public List<PostagemRespostaDto> listarPostagensPorUsuario(String autorNodeId, UsuarioAutenticado usuarioLogado) {
        if (autorNodeId == null || autorNodeId.isBlank()) {
            return Collections.emptyList();
        }
        String limpo = autorNodeId.trim();
        List<String> nodeIds = new ArrayList<>();
        nodeIds.add(limpo);
        if (limpo.startsWith("@")) {
            nodeIds.add(limpo.substring(1));
        } else {
            nodeIds.add("@" + limpo);
        }

        List<Postagem> postagens = postagemRepository.findByAutorNodeIdInOrderByCriadoEmDesc(nodeIds);

        List<String> identificadores = extrairIdentificadores(postagens);
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return postagens.stream()
                .map(p -> mapearParaRespostaDto(p, usuarioLogado, obterPerfilDoMap(p, perfisMap)))
                .toList();
    }

    public List<PostagemRespostaDto> buscarPostagens(String query, UsuarioAutenticado usuarioLogado) {
        if (query == null || query.isBlank()) {
            return List.of();
        }
        List<Postagem> postagens = postagemRepository.findByConteudoContainingIgnoreCaseOrderByCriadoEmDesc(query.trim());
        List<String> identificadores = extrairIdentificadores(postagens);
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return postagens.stream()
                .map(p -> mapearParaRespostaDto(p, usuarioLogado, obterPerfilDoMap(p, perfisMap)))
                .toList();
    }

    public PostagemRespostaDto buscarPorId(String id, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(id)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + id));

        List<String> identificadores = extrairIdentificadores(List.of(postagem));
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return mapearParaRespostaDto(postagem, usuarioLogado, obterPerfilDoMap(postagem, perfisMap));
    }

    public PostagemRespostaDto alternarCurtida(String id, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(id)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + id));

        String identificador = usuarioLogado.getNodeId();
        if (postagem.getCurtidas() == null) {
            postagem.setCurtidas(new HashSet<>());
        }

        if (postagem.getCurtidas().contains(identificador)) {
            postagem.getCurtidas().remove(identificador);
        } else {
            postagem.getCurtidas().add(identificador);
        }

        postagem.setQuantidadeCurtidas(postagem.getCurtidas().size());
        postagem.setAtualizadoEm(LocalDateTime.now());

        Postagem atualizada = postagemRepository.save(postagem);
        
        List<String> identificadores = extrairIdentificadores(List.of(atualizada));
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return mapearParaRespostaDto(atualizada, usuarioLogado, obterPerfilDoMap(atualizada, perfisMap));
    }

    public void excluirPostagem(String id, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(id)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + id));

        boolean ehAutor = (postagem.getAutorNodeId() != null && postagem.getAutorNodeId().equals(usuarioLogado.getNodeId()))
                || (postagem.getAutorId() != null && postagem.getAutorId().equals(usuarioLogado.getId()));

        if (!ehAutor) {
            throw new AcessoNegadoException("Você não tem permissão para excluir esta publicação.");
        }

        postagemRepository.delete(postagem);
    }

    // --- Métodos Auxiliares ---

    private List<String> extrairIdentificadores(List<Postagem> postagens) {
        Set<String> idsUnicos = new HashSet<>();
        for (Postagem p : postagens) {
            if (p.getAutorId() != null) idsUnicos.add(p.getAutorId());
            if (p.getAutorNodeId() != null) idsUnicos.add(p.getAutorNodeId());
        }
        return new ArrayList<>(idsUnicos);
    }

    private Map<String, PerfilResumidoDto> buscarPerfisEmLote(List<String> autorIds) {
        if (autorIds == null || autorIds.isEmpty()) {
            return Collections.emptyMap();
        }
        try {
            var resposta = authClient.buscarPerfisEmLote(autorIds);
            if (resposta != null && resposta.getData() != null) {
                Map<String, PerfilResumidoDto> mapa = new HashMap<>();
                for (PerfilResumidoDto perfil : resposta.getData()) {
                    if (perfil.getId() != null) {
                        mapa.put(perfil.getId(), perfil);
                    }
                    if (perfil.getNodeId() != null) {
                        // Garante que o post antigo ache o perfil mesmo buscando pelo @handle/nodeId ou com @
                        mapa.put(perfil.getNodeId(), perfil);
                        mapa.put("@" + perfil.getNodeId(), perfil);
                    }
                }
                return mapa;
            }
        } catch (Exception e) {
            log.error("Erro ao sincronizar perfis em lote via auth-service: {}", e.getMessage(), e);
        }
        return Collections.emptyMap();
    }

    private PerfilResumidoDto obterPerfilDoMap(Postagem postagem, Map<String, PerfilResumidoDto> perfisMap) {
        if (perfisMap.isEmpty()) return null;
        if (postagem.getAutorId() != null && perfisMap.containsKey(postagem.getAutorId())) {
            return perfisMap.get(postagem.getAutorId());
        }
        if (postagem.getAutorNodeId() != null) {
            String nodeId = postagem.getAutorNodeId();
            if (perfisMap.containsKey(nodeId)) {
                return perfisMap.get(nodeId);
            }
            if (!nodeId.startsWith("@") && perfisMap.containsKey("@" + nodeId)) {
                return perfisMap.get("@" + nodeId);
            }
            if (nodeId.startsWith("@") && perfisMap.containsKey(nodeId.substring(1))) {
                return perfisMap.get(nodeId.substring(1));
            }
        }
        return null;
    }

    private PostagemRespostaDto mapearParaRespostaDto(Postagem postagem, UsuarioAutenticado usuarioLogado, PerfilResumidoDto perfilAtual) {
        boolean curtido = false;
        if (usuarioLogado != null && postagem.getCurtidas() != null) {
            curtido = postagem.getCurtidas().contains(usuarioLogado.getNodeId()) 
                    || (usuarioLogado.getId() != null && postagem.getCurtidas().contains(usuarioLogado.getId()));
        }

        String dataCriacaoFormatada = formatarDataIso(postagem.getCriadoEm());
        String dataAtualizacaoFormatada = formatarDataIso(postagem.getAtualizadoEm());

        String nomeAutor = (perfilAtual != null && perfilAtual.getNome() != null) 
                ? perfilAtual.getNome() : postagem.getAutorNome();
        String handleAutor = (perfilAtual != null && perfilAtual.getNodeId() != null) 
                ? perfilAtual.getNodeId() : postagem.getAutorNodeId();
        String avatarAutor = (perfilAtual != null) 
                ? perfilAtual.getAvatarUrl() : postagem.getAutorAvatarUrl();

        return PostagemRespostaDto.builder()
                .id(postagem.getId())
                .authorName(nomeAutor)
                .authorId(handleAutor)
                .authorAvatarUrl(avatarAutor)
                .content(postagem.getConteudo())
                .createdAt(dataCriacaoFormatada)
                .updatedAt(dataAtualizacaoFormatada)
                .likes(postagem.getQuantidadeCurtidas())
                .comments(postagem.getQuantidadeComentarios())
                .curtidoPeloUsuario(curtido)
                .build();
    }

    private String formatarDataIso(LocalDateTime data) {
        if (data == null) {
            return null;
        }
        return data.atZone(ZoneId.systemDefault()).format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
    }
}