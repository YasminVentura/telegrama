package com.example.post.repositorio;

import com.example.post.modelo.Postagem;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PostagemRepository extends MongoRepository<Postagem, String> {

    Page<Postagem> findAllByOrderByCriadoEmDesc(Pageable pageable);

    List<Postagem> findByAutorNodeIdOrderByCriadoEmDesc(String autorNodeId);

    List<Postagem> findByAutorNodeIdInOrderByCriadoEmDesc(List<String> autorNodeIds);

    List<Postagem> findByCurtidasInOrderByCriadoEmDesc(List<String> nodeIds);

    List<Postagem> findBySalvosInOrderByCriadoEmDesc(List<String> nodeIds);

    List<Postagem> findByConteudoContainingIgnoreCaseOrderByCriadoEmDesc(String conteudo);

    void deleteByAutorNodeIdIn(List<String> autorNodeIds);
}
