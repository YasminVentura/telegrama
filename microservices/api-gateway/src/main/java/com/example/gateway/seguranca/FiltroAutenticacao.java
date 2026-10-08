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
        
        // Obter o cookie idSessao
        HttpCookie cookieSessao = request.getCookies().getFirst("idSessao");
        
        if (cookieSessao != null) {
            try {
                // Decodificar o JWT
                String jwt = UtilidadesCriptografia.descriptografar(cookieSessao.getValue());
                
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
