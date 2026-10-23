package com.example.post.seguranca;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.function.Function;

@Component
public class JwtUtils {

    @Value("${jwt.secret}")
    private String secret;

    private SecretKey getSigningKey() {
        byte[] keyBytes = secret.getBytes();
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public String extrairSubject(String token) {
        return extrairClaim(token, Claims::getSubject);
    }

    public <T> T extrairClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extrairTodasClaims(token);
        return claimsResolver.apply(claims);
    }

    public Claims extrairTodasClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public boolean isTokenValido(String token) {
        try {
            return !isTokenExpirado(token);
        } catch (Exception e) {
            return false;
        }
    }

    private boolean isTokenExpirado(String token) {
        return extrairClaim(token, Claims::getExpiration).before(new Date());
    }

    public UsuarioAutenticado extrairUsuario(String token) {
        Claims claims = extrairTodasClaims(token);
        String nodeId = claims.getSubject();
        String nome = (String) claims.get("nome");
        String id = (String) claims.get("id");

        if (nome == null || nome.isBlank()) {
            nome = nodeId;
        }

        return UsuarioAutenticado.builder()
                .id(id)
                .nodeId(nodeId)
                .nome(nome)
                .build();
    }
}
