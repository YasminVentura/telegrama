package com.example.profile.repositorio;

import com.example.profile.modelo.PerfilUsuario;
import com.example.profile.modelo.Seguidor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface SeguidorRepository extends JpaRepository<Seguidor, UUID> {

    long countBySeguido(PerfilUsuario seguido);

    long countBySeguidor(PerfilUsuario seguidor);

    boolean existsBySeguidorAndSeguido(PerfilUsuario seguidor, PerfilUsuario seguido);

    Optional<Seguidor> findBySeguidorAndSeguido(PerfilUsuario seguidor, PerfilUsuario seguido);

    void deleteBySeguidorOrSeguido(PerfilUsuario seguidor, PerfilUsuario seguido);
}
