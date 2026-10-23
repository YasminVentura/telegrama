package com.example.post.servico;

import com.example.post.dto.CriarPostagemRequisicaoDto;
import com.example.post.dto.PostagemRespostaDto;
import com.example.post.excecao.AcessoNegadoException;
import com.example.post.excecao.PostagemNaoEncontradaException;
import com.example.post.modelo.Postagem;
import com.example.post.repositorio.PostagemRepository;
import com.example.post.seguranca.UsuarioAutenticado;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PostagemService {

    private final PostagemRepository postagemRepository;

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
        return mapearParaRespostaDto(salva, autor);
    }

    public List<PostagemRespostaDto> listarPostagens(int pagina, int limite, UsuarioAutenticado usuarioLogado) {
        int paginaIndex = Math.max(0, pagina - 1);
        int limiteValido = Math.max(1, limite);
        Pageable pageable = PageRequest.of(paginaIndex, limiteValido);

        return postagemRepository.findAllByOrderByCriadoEmDesc(pageable)
                .getContent()
                .stream()
                .map(p -> mapearParaRespostaDto(p, usuarioLogado))
                .toList();
    }

    public PostagemRespostaDto buscarPorId(String id, UsuarioAutenticado usuarioLogado) {
        Postagem postagem = postagemRepository.findById(id)
                .orElseThrow(() -> new PostagemNaoEncontradaException("Publicação não encontrada com id: " + id));

        return mapearParaRespostaDto(postagem, usuarioLogado);
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
        return mapearParaRespostaDto(atualizada, usuarioLogado);
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

    private PostagemRespostaDto mapearParaRespostaDto(Postagem postagem, UsuarioAutenticado usuarioLogado) {
        boolean curtido = false;
        if (usuarioLogado != null && postagem.getCurtidas() != null) {
            curtido = postagem.getCurtidas().contains(usuarioLogado.getNodeId()) 
                    || (usuarioLogado.getId() != null && postagem.getCurtidas().contains(usuarioLogado.getId()));
        }

        String dataCriacaoFormatada = formatarDataIso(postagem.getCriadoEm());
        String dataAtualizacaoFormatada = formatarDataIso(postagem.getAtualizadoEm());

        return PostagemRespostaDto.builder()
                .id(postagem.getId())
                .authorName(postagem.getAutorNome())
                .authorId(postagem.getAutorNodeId())
                .authorAvatarUrl(postagem.getAutorAvatarUrl())
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
