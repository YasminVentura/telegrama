package com.example.authetication.repositorio;

import com.example.authetication.modelo.Seguidor;
import com.example.authetication.modelo.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface SeguidorRepository extends JpaRepository<Seguidor, UUID> {

    long countBySeguido(Usuario seguido);

    long countBySeguidor(Usuario seguidor);

    boolean existsBySeguidorAndSeguido(Usuario seguidor, Usuario seguido);

    java.util.Optional<Seguidor> findBySeguidorAndSeguido(Usuario seguidor, Usuario seguido);
}
