package com.example.gateway.seguranca;

import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.http.HttpCookie;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class FiltroAutenticacao implements GlobalFilter, Ordered {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();
        
        String idSessao = null;

        // 1. Tentar obter pelo cookie parseado
        HttpCookie cookieSessao = request.getCookies().getFirst("idSessao");
        if (cookieSessao != null) {
            idSessao = cookieSessao.getValue();
        }

        // 2. Tentar obter pelo header X-Session-Id
        if (idSessao == null || idSessao.isBlank()) {
            idSessao = request.getHeaders().getFirst("X-Session-Id");
        }

        // 3. Tentar obter pelo header Cookie em formato de texto bruto
        if (idSessao == null || idSessao.isBlank()) {
            String cookieHeader = request.getHeaders().getFirst("Cookie");
            if (cookieHeader != null && cookieHeader.contains("idSessao=")) {
                for (String parte : cookieHeader.split(";")) {
                    String limpa = parte.trim();
                    if (limpa.startsWith("idSessao=")) {
                        idSessao = limpa.substring("idSessao=".length());
                        break;
                    }
                }
            }
        }
        
        if (idSessao != null && !idSessao.isBlank()) {
            try {
                // Decodificar o JWT
                String jwt = UtilidadesCriptografia.descriptografar(idSessao);
                
                // Injetar o cabeçalho Authorization
                request = request.mutate()
                        .header("Authorization", "Bearer " + jwt)
                        .build();
                
                return chain.filter(exchange.mutate().request(request).build());
            } catch (Exception e) {
                // Se a decodificação falhar, apenas segue o fluxo sem injetar
                System.out.println("Falha ao decodificar idSessao: " + e.getMessage());
            }
        }
        
        return chain.filter(exchange);
    }

    @Override
    public int getOrder() {
        return -1; // Executar antes do roteamento padrão
    }
}
