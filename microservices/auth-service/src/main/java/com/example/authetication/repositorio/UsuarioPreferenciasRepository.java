package com.example.authetication.repositorio;

import com.example.authetication.modelo.Usuario;
import com.example.authetication.modelo.UsuarioPreferencias;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface UsuarioPreferenciasRepository extends JpaRepository<UsuarioPreferencias, UUID> {
    Optional<UsuarioPreferencias> findByUsuario(Usuario usuario);
    Optional<UsuarioPreferencias> findByUsuarioNodeId(String nodeId);
}

