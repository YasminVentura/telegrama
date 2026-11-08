package com.example.profile.repositorio;

import com.example.profile.modelo.PerfilUsuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface PerfilUsuarioRepository extends JpaRepository<PerfilUsuario, UUID> {

    Optional<PerfilUsuario> findByEmail(String email);

    Optional<PerfilUsuario> findByNodeId(String nodeId);

    Optional<PerfilUsuario> findByNodeIdIgnoreCase(String nodeId);

    boolean existsByEmail(String email);

    boolean existsByNodeId(String nodeId);

    List<PerfilUsuario> findByNomeContainingIgnoreCaseOrNodeIdContainingIgnoreCase(String nome, String nodeId);
}

