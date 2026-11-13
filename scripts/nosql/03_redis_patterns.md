# Padrões NoSQL Chave-Valor (Redis 7) - Projeto Telegrama

O **Redis** é utilizado no Telegrama para resolver dois desafios de alta concorrência e baixa latência exigidos pelo projeto:
1. **Padrão Token Mediating / Reference Token (Sessões Rápidas)**.
2. **Padrão Cache-Aside e Rotação de Refresh Token**.

---

## 1. Estrutura de Chaves e TTLs

| Prefixo da Chave | Tipo | Valor | TTL | Objetivo |
| :--- | :--- | :--- | :--- | :--- |
| `sessao:<UUID>` | String | Token JWT assinado | 24 horas (`86400s`) | Permite ao API Gateway validar a sessão em O(1) na memória RAM e injetar o JWT na requisição interna sem consultar o PostgreSQL. |
| `refresh:<UUID>` | String | `usuarioId` (UUID) | 7 dias (`604800s`) | Permite renovar a sessão do usuário de forma segura com rotação de chaves. |

---

## 2. Comandos Operacionais no Redis CLI

### Gravação no Login (Auth Service):
```redis
# 1. Armazena a sessão vinculando ao JWT gerado (expira em 24h)
SET sessao:550e8400-e29b-41d4-a716-446655440000 "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." EX 86400

# 2. Armazena o refresh token vinculado ao UUID do usuário (expira em 7 dias)
SET refresh:7c9e6679-7425-40de-944b-e07fc1f90ae7 "123e4567-e89b-12d3-a456-426614174000" EX 604800
```

### Leitura no API Gateway (FiltroAutenticacao):
```redis
# Busca instantânea (< 1ms) da sessão
GET sessao:550e8400-e29b-41d4-a716-446655440000
```

### Logout / Invalidação Imediata de Sessão:
```redis
# Revogação imediata (impossível em JWT stateless puro sem lista de revogação)
DEL sessao:550e8400-e29b-41d4-a716-446655440000
DEL refresh:7c9e6679-7425-40de-944b-e07fc1f90ae7
```

### Rotação de Refresh Token (Renovação):
```redis
# Obtém o usuário associado
GET refresh:7c9e6679-7425-40de-944b-e07fc1f90ae7

# Deleta o refresh token anterior (previne replay attack)
DEL refresh:7c9e6679-7425-40de-944b-e07fc1f90ae7

# Emite novo par de sessão e refresh token
SET sessao:<novo-uuid> <novo-jwt> EX 86400
SET refresh:<novo-refresh-uuid> <usuario-id> EX 604800
```

---

## 3. Justificativa Técnica para o Professor

1. **Substituição de I/O em Disco por Memória:** Sem o Redis, cada requisição recebida no API Gateway obrigaria uma consulta SQL no PostgreSQL para validar se o usuário ainda está ativo ou deslogado, saturando o pool de conexões do banco relacional.
2. **Revogação Instantânea com JWT Stateless:** O Redis une o melhor dos dois mundos: o cliente não expõe seu JWT no frontend (recebe um ID opaco), e o Gateway pode invalidar uma sessão no milissegundo em que o usuário clica em "Sair", algo que um JWT puro não permite.

