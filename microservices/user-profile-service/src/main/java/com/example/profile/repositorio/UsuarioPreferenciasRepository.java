package com.example.profile.repositorio;

import com.example.profile.modelo.PerfilUsuario;
import com.example.profile.modelo.UsuarioPreferencias;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UsuarioPreferenciasRepository extends JpaRepository<UsuarioPreferencias, UUID> {
    Optional<UsuarioPreferencias> findByUsuario(PerfilUsuario usuario);
    Optional<UsuarioPreferencias> findByUsuarioNodeId(String nodeId);
}
