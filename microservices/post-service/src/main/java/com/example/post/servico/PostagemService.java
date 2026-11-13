package com.example.post.servico;

import com.example.post.cliente.AuthClient;
import com.example.post.dto.ComentarioRespostaDto;
import com.example.post.dto.CriarComentarioRequisicaoDto;
import com.example.post.dto.CriarPostagemRequisicaoDto;
import com.example.post.dto.PerfilResumidoDto;
import com.example.post.dto.PostagemRespostaDto;
import com.example.post.excecao.AcessoNegadoException;
import com.example.post.excecao.PostagemNaoEncontradaException;
import com.example.post.modelo.ComentarioPostagem;
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

        List<String> idsAutor = new ArrayList<>();
        if (autor.getId() != null) idsAutor.add(autor.getId());
        if (autor.getNodeId() != null) idsAutor.add(autor.getNodeId());
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(idsAutor);
        PerfilResumidoDto perfilAutor = null;
        if (autor.getId() != null && perfisMap.containsKey(autor.getId().toLowerCase())) {
            perfilAutor = perfisMap.get(autor.getId().toLowerCase());
        } else if (autor.getNodeId() != null && perfisMap.containsKey(autor.getNodeId().toLowerCase())) {
            perfilAutor = perfisMap.get(autor.getNodeId().toLowerCase());
        }

        Postagem postagem = Postagem.builder()
                .autorId(autor.getId())
                .autorNodeId(perfilAutor != null && perfilAutor.getNodeId() != null ? perfilAutor.getNodeId() : autor.getNodeId())
                .autorNome(perfilAutor != null && perfilAutor.getNome() != null ? perfilAutor.getNome() : autor.getNome())
                .autorAvatarUrl(perfilAutor != null ? perfilAutor.getAvatarUrl() : null)
                .conteudo(requisicao.getContent())
                .curtidas(new HashSet<>())
                .salvos(new HashSet<>())
                .reposts(new HashSet<>())
                .quantidadeCurtidas(0)
                .quantidadeComentarios(0)
                .quantidadeReposts(0)
                .criadoEm(agora)
                .atualizadoEm(agora)
                .build();

        Postagem salva = postagemRepository.save(postagem);
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
        List<String> variacoes = construirVariacoesNodeId(autorNodeId);
        if (variacoes.isEmpty()) {
            return Collections.emptyList();
        }

        List<Postagem> proprias = postagemRepository.findByAutorNodeIdInOrderByCriadoEmDesc(variacoes);
        List<Postagem> repostadas = postagemRepository.findByRepostsInOrderByCriadoEmDesc(variacoes);

        Map<String, Postagem> unificadas = new LinkedHashMap<>();
        Set<String> idsRepostadosPeloPerfil = new HashSet<>();

        for (Postagem p : repostadas) {
            if (p.getId() != null) {
                unificadas.put(p.getId(), p);
                idsRepostadosPeloPerfil.add(p.getId());
            }
        }
        for (Postagem p : proprias) {
            if (p.getId() != null) {
                unificadas.put(p.getId(), p);
            }
        }

        List<Postagem> postagens = new ArrayList<>(unificadas.values());
        postagens.sort((a, b) -> {
            LocalDateTime da = a.getCriadoEm() != null ? a.getCriadoEm() : LocalDateTime.MIN;
            LocalDateTime db = b.getCriadoEm() != null ? b.getCriadoEm() : LocalDateTime.MIN;
            return db.compareTo(da);
        });

        List<String> identificadores = extrairIdentificadores(postagens);
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        String cleanPerfilAlvo = autorNodeId.trim().replaceAll("@", "");
        String handlePerfilAlvo = "@" + cleanPerfilAlvo;

        return postagens.stream()
                .map(p -> {
                    PostagemRespostaDto dto = mapearParaRespostaDto(p, usuarioLogado, obterPerfilDoMap(p, perfisMap));
                    String autorPostClean = p.getAutorNodeId() != null
                            ? p.getAutorNodeId().trim().replaceAll("@", "")
                            : "";
                    boolean naoEhAutorDoPerfil = !autorPostClean.equalsIgnoreCase(cleanPerfilAlvo);
                    boolean foiRepostadoPeloPerfil = (p.getId() != null && idsRepostadosPeloPerfil.contains(p.getId()))
                            || naoEhAutorDoPerfil;
                    if (foiRepostadoPeloPerfil) {
                        dto.setRepostadoNoPerfil(true);
                        dto.setRepostadoPor(handlePerfilAlvo);
                    }
                    return dto;
                })
                .toList();
    }

    public List<PostagemRespostaDto> listarPostagensCurtidasPorUsuario(String nodeId, UsuarioAutenticado usuarioLogado) {
        List<String> variacoes = construirVariacoesNodeId(nodeId);
        if (variacoes.isEmpty()) {
            return Collections.emptyList();
        }

        List<Postagem> postagens = postagemRepository.findByCurtidasInOrderByCriadoEmDesc(variacoes);
        List<String> identificadores = extrairIdentificadores(postagens);
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return postagens.stream()
                .map(p -> mapearParaRespostaDto(p, usuarioLogado, obterPerfilDoMap(p, perfisMap)))
                .toList();
    }

    public List<PostagemRespostaDto> listarPostagensSalvasPorUsuario(String nodeId, UsuarioAutenticado usuarioLogado) {
        List<String> variacoes = construirVariacoesNodeId(nodeId);
        if (variacoes.isEmpty()) {
            return Collections.emptyList();
        }

        List<Postagem> postagens = postagemRepository.findBySalvosInOrderByCriadoEmDesc(variacoes);
        List<String> identificadores = extrairIdentificadores(postagens);
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return postagens.stream()
                .map(p -> mapearParaRespostaDto(p, usuarioLogado, obterPerfilDoMap(p, perfisMap)))
                .toList();
    }

    private List<String> construirVariacoesNodeId(String nodeId) {
        if (nodeId == null || nodeId.isBlank()) {
            return Collections.emptyList();
        }
        String limpo = nodeId.trim();
        String semArroba = limpo.startsWith("@") ? limpo.substring(1) : limpo;
        String comArroba = "@" + semArroba;
        return List.of(semArroba, comArroba, semArroba.toLowerCase(), comArroba.toLowerCase());
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

        if (postagem.getCurtidas() == null) {
            postagem.setCurtidas(new HashSet<>());
        }

        String rawNodeId = usuarioLogado.getNodeId() != null ? usuarioLogado.getNodeId().trim() : "";
        String cleanNodeId = rawNodeId.startsWith("@") ? rawNodeId.substring(1) : rawNodeId;
        String handleNodeId = "@" + cleanNodeId;
        String userId = usuarioLogado.getId();

        boolean jaCurtiu = postagem.getCurtidas().removeIf(c ->
                c.equalsIgnoreCase(rawNodeId)
                || c.equalsIgnoreCase(cleanNodeId)
                || c.equalsIgnoreCase(handleNodeId)
                || (userId != null && c.equalsIgnoreCase(userId))
        );

        if (!jaCurtiu && !handleNodeId.equals("@")) {
            postagem.getCurtidas().add(handleNodeId);
        }

        postagem.setQuantidadeCurtidas(postagem.getCurtidas().size());
        postagem.setAtualizadoEm(LocalDateTime.now());

        Postagem atualizada = postagemRepository.save(postagem);

        List<String> identificadores = extrairIdentificadores(List.of(atualizada));
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return mapearParaRespostaDto(atualizada, usuarioLogado, obterPerfilDoMap(atualizada, perfisMap));
    }

    public PostagemRespostaDto alternarSalvo(String id, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(id)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + id));

        if (postagem.getSalvos() == null) {
            postagem.setSalvos(new HashSet<>());
        }

        String rawNodeId = usuarioLogado.getNodeId() != null ? usuarioLogado.getNodeId().trim() : "";
        String cleanNodeId = rawNodeId.startsWith("@") ? rawNodeId.substring(1) : rawNodeId;
        String handleNodeId = "@" + cleanNodeId;
        String userId = usuarioLogado.getId();

        boolean jaSalvo = postagem.getSalvos().removeIf(s ->
                s.equalsIgnoreCase(rawNodeId)
                || s.equalsIgnoreCase(cleanNodeId)
                || s.equalsIgnoreCase(handleNodeId)
                || (userId != null && s.equalsIgnoreCase(userId))
        );

        if (!jaSalvo && !handleNodeId.equals("@")) {
            postagem.getSalvos().add(handleNodeId);
        }

        Postagem atualizada = postagemRepository.save(postagem);

        List<String> identificadores = extrairIdentificadores(List.of(atualizada));
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return mapearParaRespostaDto(atualizada, usuarioLogado, obterPerfilDoMap(atualizada, perfisMap));
    }

    public PostagemRespostaDto alternarRepost(String id, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(id)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + id));

        if (postagem.getReposts() == null) {
            postagem.setReposts(new HashSet<>());
        }

        String rawNodeId = usuarioLogado.getNodeId() != null ? usuarioLogado.getNodeId().trim() : "";
        String cleanNodeId = rawNodeId.startsWith("@") ? rawNodeId.substring(1) : rawNodeId;
        String handleNodeId = "@" + cleanNodeId;
        String userId = usuarioLogado.getId();

        boolean jaRepostou = postagem.getReposts().removeIf(r ->
                r.equalsIgnoreCase(rawNodeId)
                || r.equalsIgnoreCase(cleanNodeId)
                || r.equalsIgnoreCase(handleNodeId)
                || (userId != null && r.equalsIgnoreCase(userId))
        );

        if (!jaRepostou && !handleNodeId.equals("@")) {
            postagem.getReposts().add(handleNodeId);
        }

        postagem.setQuantidadeReposts(postagem.getReposts().size());
        postagem.setAtualizadoEm(LocalDateTime.now());

        Postagem atualizada = postagemRepository.save(postagem);

        List<String> identificadores = extrairIdentificadores(List.of(atualizada));
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(identificadores);

        return mapearParaRespostaDto(atualizada, usuarioLogado, obterPerfilDoMap(atualizada, perfisMap));
    }

    public void excluirPostagem(String id, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(id)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + id));

        boolean ehAutor = (postagem.getAutorNodeId() != null && postagem.getAutorNodeId().replaceAll("@", "").equalsIgnoreCase(usuarioLogado.getNodeId().replaceAll("@", "")))
                || (postagem.getAutorId() != null && postagem.getAutorId().equals(usuarioLogado.getId()));
        boolean ehAdmin = usuarioLogado.isAdmin();

        if (!ehAutor && !ehAdmin) {
            throw new AcessoNegadoException("Você não tem permissão para excluir esta publicação.");
        }

        postagemRepository.delete(postagem);
    }

    public void excluirPostagensPorAutorInterno(String autorNodeId) {
        if (autorNodeId == null || autorNodeId.isBlank()) {
            return;
        }
        String limpo = autorNodeId.trim();
        List<String> nodeIds = new ArrayList<>();
        nodeIds.add(limpo);
        if (limpo.startsWith("@")) {
            nodeIds.add(limpo.substring(1));
        } else {
            nodeIds.add("@" + limpo);
        }
        postagemRepository.deleteByAutorNodeIdIn(nodeIds);
    }

    public List<ComentarioRespostaDto> listarComentarios(String postId, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(postId)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + postId));

        if (postagem.getComentarios() == null || postagem.getComentarios().isEmpty()) {
            return Collections.emptyList();
        }

        Set<String> autorIds = new HashSet<>();
        for (ComentarioPostagem c : postagem.getComentarios()) {
            if (c.getAutorId() != null) autorIds.add(c.getAutorId());
            if (c.getAutorNodeId() != null) autorIds.add(c.getAutorNodeId());
        }
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(new ArrayList<>(autorIds));

        Map<String, ComentarioRespostaDto> dtoPorId = new LinkedHashMap<>();
        for (ComentarioPostagem c : postagem.getComentarios()) {
            PerfilResumidoDto perfil = obterPerfilAutor(c.getAutorId(), c.getAutorNodeId(), perfisMap);
            ComentarioRespostaDto dto = mapearComentarioParaDto(c, usuarioLogado, perfil);
            String cid = c.getId();
            if (cid != null && !cid.isBlank()) {
                dtoPorId.put(cid, dto);
            }
        }

        List<ComentarioRespostaDto> raizes = new ArrayList<>();
        for (ComentarioPostagem c : postagem.getComentarios()) {
            String cid = c.getId();
            ComentarioRespostaDto atual = cid != null ? dtoPorId.get(cid) : mapearComentarioParaDto(c, usuarioLogado, null);
            if (atual == null) continue;

            String parentId = c.getParentId();
            if (parentId != null && !parentId.isBlank() && dtoPorId.containsKey(parentId)) {
                dtoPorId.get(parentId).getReplies().add(atual);
            } else {
                raizes.add(atual);
            }
        }

        return raizes;
    }

    public ComentarioRespostaDto adicionarComentario(
            String postId,
            CriarComentarioRequisicaoDto requisicao,
            UsuarioAutenticado autor
    ) {
        Postagem postagem = postagemRepository.findById(postId)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + postId));

        if (postagem.getComentarios() == null) {
            postagem.setComentarios(new ArrayList<>());
        }

        List<String> idsAutor = new ArrayList<>();
        if (autor.getId() != null) idsAutor.add(autor.getId());
        if (autor.getNodeId() != null) idsAutor.add(autor.getNodeId());
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(idsAutor);
        PerfilResumidoDto perfilAutor = obterPerfilAutor(autor.getId(), autor.getNodeId(), perfisMap);

        String parentId = (requisicao.getParentId() != null && !requisicao.getParentId().isBlank())
                ? requisicao.getParentId().trim()
                : null;

        String novoId = UUID.randomUUID().toString();
        ComentarioPostagem novoComentario = ComentarioPostagem.builder()
                .id(novoId)
                .idLegado(novoId)
                .parentId(parentId)
                .autorId(autor.getId())
                .autorNodeId(perfilAutor != null && perfilAutor.getNodeId() != null ? perfilAutor.getNodeId() : autor.getNodeId())
                .autorNome(perfilAutor != null && perfilAutor.getNome() != null ? perfilAutor.getNome() : autor.getNome())
                .autorAvatarUrl(perfilAutor != null ? perfilAutor.getAvatarUrl() : null)
                .conteudo(requisicao.getContent().trim())
                .curtidas(new HashSet<>())
                .criadoEm(LocalDateTime.now())
                .build();

        postagem.getComentarios().add(novoComentario);
        postagem.setQuantidadeComentarios(postagem.getComentarios().size());
        postagem.setAtualizadoEm(LocalDateTime.now());
        postagemRepository.save(postagem);

        return mapearComentarioParaDto(novoComentario, autor, perfilAutor);
    }

    public ComentarioRespostaDto alternarCurtidaComentario(
            String postId,
            String comentarioId,
            UsuarioAutenticado usuarioLogado
    ) {
        Postagem postagem = postagemRepository.findById(postId)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + postId));

        if (postagem.getComentarios() == null) {
            throw new PostagemNaoEncontradaException("Comentário não encontrado: " + comentarioId);
        }

        ComentarioPostagem alvo = postagem.getComentarios().stream()
                .filter(c -> c.getId() != null && c.getId().equals(comentarioId))
                .findFirst()
                .orElseThrow(() -> new PostagemNaoEncontradaException("Comentário não encontrado: " + comentarioId));

        if (alvo.getCurtidas() == null) {
            alvo.setCurtidas(new HashSet<>());
        }

        String rawNodeId = usuarioLogado.getNodeId() != null ? usuarioLogado.getNodeId().trim() : "";
        String cleanNodeId = rawNodeId.startsWith("@") ? rawNodeId.substring(1) : rawNodeId;
        String handleNodeId = "@" + cleanNodeId;
        String userId = usuarioLogado.getId();

        boolean jaCurtiu = alvo.getCurtidas().removeIf(c ->
                c.equalsIgnoreCase(rawNodeId)
                || c.equalsIgnoreCase(cleanNodeId)
                || c.equalsIgnoreCase(handleNodeId)
                || (userId != null && c.equalsIgnoreCase(userId))
        );

        if (!jaCurtiu && !handleNodeId.equals("@")) {
            alvo.getCurtidas().add(handleNodeId);
        }

        postagemRepository.save(postagem);

        List<String> idsAutor = new ArrayList<>();
        if (alvo.getAutorId() != null) idsAutor.add(alvo.getAutorId());
        if (alvo.getAutorNodeId() != null) idsAutor.add(alvo.getAutorNodeId());
        Map<String, PerfilResumidoDto> perfisMap = buscarPerfisEmLote(idsAutor);
        PerfilResumidoDto perfilAutor = obterPerfilAutor(alvo.getAutorId(), alvo.getAutorNodeId(), perfisMap);

        return mapearComentarioParaDto(alvo, usuarioLogado, perfilAutor);
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
                        mapa.put(perfil.getId().toLowerCase(), perfil);
                    }
                    if (perfil.getNodeId() != null) {
                        String raw = perfil.getNodeId().trim();
                        String semArroba = raw.startsWith("@") ? raw.substring(1) : raw;
                        String comArroba = "@" + semArroba;
                        mapa.put(raw, perfil);
                        mapa.put(semArroba, perfil);
                        mapa.put(comArroba, perfil);
                        mapa.put(semArroba.toLowerCase(), perfil);
                        mapa.put(comArroba.toLowerCase(), perfil);
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
        return obterPerfilAutor(postagem.getAutorId(), postagem.getAutorNodeId(), perfisMap);
    }

    private PerfilResumidoDto obterPerfilAutor(String autorId, String autorNodeId, Map<String, PerfilResumidoDto> perfisMap) {
        if (perfisMap.isEmpty()) return null;
        if (autorId != null) {
            if (perfisMap.containsKey(autorId)) {
                return perfisMap.get(autorId);
            }
            if (perfisMap.containsKey(autorId.toLowerCase())) {
                return perfisMap.get(autorId.toLowerCase());
            }
        }
        if (autorNodeId != null) {
            String nodeId = autorNodeId.trim();
            String semArroba = nodeId.startsWith("@") ? nodeId.substring(1) : nodeId;
            String comArroba = "@" + semArroba;
            for (String chave : List.of(nodeId, semArroba, comArroba, semArroba.toLowerCase(), comArroba.toLowerCase())) {
                if (perfisMap.containsKey(chave)) {
                    return perfisMap.get(chave);
                }
            }
        }
        return null;
    }

    private ComentarioRespostaDto mapearComentarioParaDto(
            ComentarioPostagem comentario,
            UsuarioAutenticado usuarioLogado,
            PerfilResumidoDto perfilAtual
    ) {
        boolean curtido = false;
        if (usuarioLogado != null && comentario.getCurtidas() != null) {
            String rawNodeId = usuarioLogado.getNodeId() != null ? usuarioLogado.getNodeId().trim() : "";
            String cleanNodeId = rawNodeId.startsWith("@") ? rawNodeId.substring(1) : rawNodeId;
            String handleNodeId = "@" + cleanNodeId;
            String userId = usuarioLogado.getId();

            curtido = comentario.getCurtidas().stream().anyMatch(c ->
                    c.equalsIgnoreCase(rawNodeId)
                    || c.equalsIgnoreCase(cleanNodeId)
                    || c.equalsIgnoreCase(handleNodeId)
                    || (userId != null && c.equalsIgnoreCase(userId))
            );
        }

        int totalCurtidas = comentario.getCurtidas() != null ? comentario.getCurtidas().size() : 0;
        String nomeAutor = (perfilAtual != null && perfilAtual.getNome() != null)
                ? perfilAtual.getNome() : comentario.getAutorNome();
        String handleAutor = (perfilAtual != null && perfilAtual.getNodeId() != null)
                ? perfilAtual.getNodeId() : comentario.getAutorNodeId();
        String avatarAutor = (perfilAtual != null)
                ? perfilAtual.getAvatarUrl() : comentario.getAutorAvatarUrl();

        return ComentarioRespostaDto.builder()
                .id(comentario.getId())
                .parentId(comentario.getParentId())
                .authorName(nomeAutor)
                .authorId(handleAutor)
                .authorAvatarUrl(avatarAutor)
                .content(comentario.getConteudo())
                .createdAt(formatarDataIso(comentario.getCriadoEm()))
                .likes(totalCurtidas)
                .curtidoPeloUsuario(curtido)
                .replies(new ArrayList<>())
                .build();
    }

    private PostagemRespostaDto mapearParaRespostaDto(Postagem postagem, UsuarioAutenticado usuarioLogado, PerfilResumidoDto perfilAtual) {
        boolean curtido = false;
        boolean salvo = false;
        boolean repostado = false;
        if (usuarioLogado != null) {
            String rawNodeId = usuarioLogado.getNodeId() != null ? usuarioLogado.getNodeId().trim() : "";
            String cleanNodeId = rawNodeId.startsWith("@") ? rawNodeId.substring(1) : rawNodeId;
            String handleNodeId = "@" + cleanNodeId;
            String userId = usuarioLogado.getId();

            if (postagem.getCurtidas() != null) {
                curtido = postagem.getCurtidas().stream().anyMatch(c ->
                        c.equalsIgnoreCase(rawNodeId)
                        || c.equalsIgnoreCase(cleanNodeId)
                        || c.equalsIgnoreCase(handleNodeId)
                        || (userId != null && c.equalsIgnoreCase(userId))
                );
            }
            if (postagem.getSalvos() != null) {
                salvo = postagem.getSalvos().stream().anyMatch(s ->
                        s.equalsIgnoreCase(rawNodeId)
                        || s.equalsIgnoreCase(cleanNodeId)
                        || s.equalsIgnoreCase(handleNodeId)
                        || (userId != null && s.equalsIgnoreCase(userId))
                );
            }
            if (postagem.getReposts() != null) {
                repostado = postagem.getReposts().stream().anyMatch(r ->
                        r.equalsIgnoreCase(rawNodeId)
                        || r.equalsIgnoreCase(cleanNodeId)
                        || r.equalsIgnoreCase(handleNodeId)
                        || (userId != null && r.equalsIgnoreCase(userId))
                );
            }
        }

        int totalCurtidas = postagem.getCurtidas() != null
                ? postagem.getCurtidas().size()
                : postagem.getQuantidadeCurtidas();

        int totalComentarios = (postagem.getComentarios() != null && !postagem.getComentarios().isEmpty())
                ? postagem.getComentarios().size()
                : postagem.getQuantidadeComentarios();

        int totalReposts = postagem.getReposts() != null
                ? postagem.getReposts().size()
                : postagem.getQuantidadeReposts();

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
                .likes(totalCurtidas)
                .comments(totalComentarios)
                .reposts(totalReposts)
                .curtidoPeloUsuario(curtido)
                .salvoPeloUsuario(salvo)
                .repostadoPeloUsuario(repostado)
                .build();
    }

    private String formatarDataIso(LocalDateTime data) {
        if (data == null) {
            return null;
        }
        return data.atZone(ZoneId.systemDefault()).format(DateTimeFormatter.ISO_OFFSET_DATE_TIME);
    }
}
