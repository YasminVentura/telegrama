package com.example.authetication.repositorio;

import com.example.authetication.modelo.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, UUID> {

    Optional<Usuario> findByEmail(String email);

    Optional<Usuario> findByNodeId(String nodeId);

    // Essencial para permitir que o usuário logue tanto com email quanto com @node_id
    Optional<Usuario> findByEmailOrNodeId(String email, String nodeId);

    boolean existsByEmail(String email);

    boolean existsByNodeId(String nodeId);

    java.util.List<Usuario> findByNomeContainingIgnoreCaseOrNodeIdContainingIgnoreCase(String nome, String nodeId);
}
