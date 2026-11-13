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

    Optional<Usuario> findByNodeIdIgnoreCase(String nodeId);

    Optional<Usuario> findByEmailOrNodeId(String email, String nodeId);

    boolean existsByEmail(String email);

    boolean existsByNodeId(String nodeId);

    boolean existsByNodeIdIgnoreCase(String nodeId);
}
