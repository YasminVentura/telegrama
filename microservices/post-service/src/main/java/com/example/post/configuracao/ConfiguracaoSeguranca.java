package com.example.post.configuracao;

import com.example.post.seguranca.JwtFiltroAutenticacao;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class ConfiguracaoSeguranca {

    private final JwtFiltroAutenticacao jwtFiltroAutenticacao;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .csrf(AbstractHttpConfigurer::disable)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // Leitura pública de posts (Feed / busca)
                        .requestMatchers(HttpMethod.GET, "/posts/**", "/api/posts/**").permitAll()
                        // Apenas usuários autenticados com token válido podem criar post, curtir ou excluir
                        .requestMatchers(HttpMethod.POST, "/posts/**", "/api/posts/**").authenticated()
                        .requestMatchers(HttpMethod.DELETE, "/posts/**", "/api/posts/**").authenticated()
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtFiltroAutenticacao, UsernamePasswordAuthenticationFilter.class)
                .build();
    }
}
