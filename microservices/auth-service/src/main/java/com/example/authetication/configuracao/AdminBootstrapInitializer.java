package com.example.authetication.configuracao;

import com.example.authetication.cliente.UserProfileClient;
import com.example.authetication.dto.CriarPerfilInternoRequisicaoDto;
import com.example.authetication.modelo.Role;
import com.example.authetication.modelo.Usuario;
import com.example.authetication.repositorio.UsuarioRepository;
import com.example.authetication.servico.UsuarioService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Slf4j
@Component
@RequiredArgsConstructor
public class AdminBootstrapInitializer implements CommandLineRunner {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserProfileClient userProfileClient;

    @Value("${admin.node-id:@admin}")
    private String adminNodeId;

    @Value("${admin.email:admin@telegrama.zone}")
    private String adminEmail;

    @Value("${admin.password:Admin@123}")
    private String adminPassword;

    @Value("${admin.nome:Moderador Central}")
    private String adminNome;

    @Override
    @Transactional
    public void run(String... args) {
        try {
            Optional<Usuario> existente = usuarioRepository.findByEmailOrNodeId(adminEmail, adminNodeId);
            Usuario admin;

            if (existente.isPresent()) {
                admin = existente.get();
                if (admin.getPerfil() != Role.ADMIN) {
                    admin.setPerfil(Role.ADMIN);
                    admin = usuarioRepository.save(admin);
                    log.info("Conta {} promovida para ADMIN.", admin.getNodeId());
                }
            } else {
                Usuario novoAdmin = Usuario.builder()
                        .nome(adminNome)
                        .nodeId(adminNodeId.startsWith("@") ? adminNodeId : "@" + adminNodeId)
                        .email(adminEmail)
                        .senha(passwordEncoder.encode(adminPassword))
                        .termosAceitos(true)
                        .perfil(Role.ADMIN)
                        .build();

                admin = usuarioRepository.save(novoAdmin);
                log.info("Conta ADMIN padrão criada: {} ({})", admin.getNodeId(), admin.getEmail());
            }

            try {
                userProfileClient.criarOuSincronizarPerfil(
                        CriarPerfilInternoRequisicaoDto.builder()
                                .id(admin.getId())
                                .nome(admin.getNome())
                                .nodeId(admin.getNodeId())
                                .email(admin.getEmail())
                                .avatarUrl(UsuarioService.AVATAR_PADRAO)
                                .perfil(Role.ADMIN)
                                .build()
                );
            } catch (Exception e) {
                log.debug("user-profile-service ainda não disponível no bootstrap (será sincronizado no login): {}", e.getMessage());
            }
        } catch (Exception e) {
            log.warn("Erro ao inicializar conta ADMIN padrão: {}", e.getMessage());
        }
    }
}
