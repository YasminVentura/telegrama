# UNIVERSIDADE FEDERAL DE ALAGOAS - UFAL
## CAMPUS ARAPIRACA - UNIDADE EDUCACIONAL PENEDO
### CURSO DE BACHARELADO EM SISTEMAS DE INFORMAÇÃO (6º PERÍODO)
### DISCIPLINA: BANCO DE DADOS II
**Docente:** Prof. Dr. Jario José dos Santos Júnior  
**Discentes:** Bruno Hollyver Alves dos Mártires e Yasmin Gomes Ventura  
**Ano:** 2026  

---

# TELEGRAMA: REDE SOCIAL COM PERSISTÊNCIA POLIGLOTA E ARQUITETURA DE MICROSSERVIÇOS
## Relatório Técnico-Científico e Divisão de Contribuições

---

## Sumário
1. [Introdução e Visão Geral](#1-introdução-e-visão-geral)
2. [Engenharia de Requisitos e Modelagem Conceitual](#2-engenharia-de-requisitos-e-modelagem-conceitual)
3. [Arquitetura de Microsserviços e Persistência Poliglota](#3-arquitetura-de-microsserviços-e-persistência-poliglota)
4. [Análise Arquitetural: Remoção do Feed Service](#4-análise-arquitetural-remoção-do-feed-service)
5. [Modelagem de Dados e Regras Críticas no SGBD](#5-modelagem-de-dados-e-regras-críticas-no-sgbd)
6. [Estudo de Desempenho e Benchmarking (SQL e NoSQL)](#6-estudo-de-desempenho-e-benchmarking-sql-e-nosql)
7. [Fluxos Operacionais e Integração Distribuída](#7-fluxos-operacionais-e-integração-distribuída)
8. [Histórico e Divisão Empírica de Contribuições (Auditoria Git)](#8-histórico-e-divisão-empírica-de-contribuições-auditoria-git)
9. [Conclusão e Considerações Finais](#9-conclusão-e-considerações-finais)
10. [Referências Bibliográficas](#10-referências-bibliográficas)

---

## 1. Introdução e Visão Geral

O projeto **Telegrama** foi concebido em contraposição à hiperestimulação sensorial e aos algoritmos viciantes que caracterizam as redes sociais contemporâneas. Inspirado na filosofia **Slow Tech** (tecnologia calma) e na estética minimalista da computação do início dos anos 2000, o Telegrama resgata a pureza das comunicações digitais através de uma interface baseada em monitores de fósforo verde/âmbar, paletas neutras e tipografia monoespaçada.

Ao contrário das plataformas comerciais focadas em prender a atenção por meio de ranqueamentos opacos e notificações invasivas, o Telegrama adota:
- **Entrega Cronológica Pura:** O feed de publicações reflete a ordem temporal estrita das emissões, sem reordenação arbitrária.
- **Soberania do Usuário:** Controle total sobre temas visuais (*Retro Green, Cyberpunk Dark, Sunset Synthwave, Monokai Hacker, Cream Espresso*), modos de privacidade e frequências de transmissão.
- **Engenharia de Dados Resiliente:** Por trás de uma estética limpa e sem distrações, opera um ecossistema poliglota distribuído de alta disponibilidade capaz de processar volumes massivos de escrita e leitura em tempo real.

---

## 2. Engenharia de Requisitos e Modelagem Conceitual

### 2.1. Requisitos Funcionais (RF)
- **RF 01 - Cadastro de Usuários:** Registro com credenciais únicas (`nodeId` iniciado por `@`, e-mail exclusivo e senha segura) e aceite de termos.
- **RF 02 - Serviço de Autenticação e Sessão:** Mecanismos de login, validação de hash BCrypt e emissão de tokens de referência opacos vinculados a sessões no Redis.
- **RF 03 - Publicação de Posts (Transmissões):** Criação e armazenamento dinâmico de postagens em texto de até 280 caracteres com carimbos temporais auditados.
- **RF 04 - Feed de Postagens:** Exibição de publicações cronológicas com paginação ágil e enriquecimento de dados em lote. Acesso público permitido em modo visitante.
- **RF 05 - Comentários e Respostas Aninhadas:** Interação via comentários em árvore (*threaded replies*) preservando integridade do nó pai (`parentId`).
- **RF 06 - Curtidas e Interações Sociais:** Registro atômico e idempotente de curtidas, reposts e salvamentos com contadores consistentes.
- **RF 07 - Serviço de Pesquisa:** Busca de perfis e publicações por nome civil, identificador de nó (`@nodeId`) ou termo textual.
- **RF 08 - Perfis e Preferências:** Edição de dados biográficos, temas visuais, alertas de transmissão e gestão do grafo direcionado de seguidores (seguir/deixar de seguir).

### 2.2. Requisitos Não Funcionais (RNF)
- **RNF 01 - Desempenho do Feed:** Tempo de resposta da primeira página de publicações inferior a **500 milissegundos** sob condições normais de concorrência.
- **RNF 02 - Segurança da Informação:** Armazenamento de senhas obrigatoriamente protegido por **BCrypt** (custo 10); isolamento de credenciais em cookies seguros (`HttpOnly`, `SameSite=Lax`).
- **RNF 03 - Portabilidade e Implantação:** Empacotamento integral da infraestrutura via **Docker Compose**, executável com um único comando.
- **RNF 04 - Usabilidade e Aderência ao Slow Tech:** Design calmo, eliminação de notificações intrusivas e navegação ergonômica sem sobrecarga cognitiva.

---

## 3. Arquitetura de Microsserviços e Persistência Poliglota

O Telegrama adota o padrão **Database-per-Service**, onde cada microsserviço possui domínio exclusivo sobre o seu mecanismo de persistência:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PERSISTÊNCIA POLIGLOTA                           │
├─────────────────────┬───────────────────────────────┬───────────────────────┤
│ SGBD Relacional     │ SGBD Não-Relacional           │ SGBD Não-Relacional   │
│ (PostgreSQL 15)     │ Documentos (MongoDB 6.0)      │ Chave-Valor (Redis 7) │
├─────────────────────┼───────────────────────────────┼───────────────────────┤
│ - telegrama_auth    │ - telegrama_posts             │ - Cache de Sessão     │
│ - telegrama_profile │ - Comentários em árvore       │ - Refresh Tokens      │
│ - 3FN & ACID        │ - Curtidas e reposts flexíveis│ - Latência < 1ms      │
│ - Triggers & Views  │ - Alta vazão de escrita       │ - TTL Automático      │
└─────────────────────┴───────────────────────────────┴───────────────────────┘
```

### 3.1. PostgreSQL 15 (Transações ACID, Credenciais e Grafo Social)
- **Bancos Isolados:** `telegrama_auth` (credenciais seguras e logs de auditoria) e `telegrama_profile` (perfis normalizados, preferências 1:1 e tabela `seguidores`).
- **Justificativa:** Operações de amizade e vínculos sociais exigem garantias transacionais rígidas (ACID) e integridade referencial com chaves estrangeiras (`ON DELETE CASCADE`). O SGBD relacional impede anomalias conceituais como auto-seguimento ou vínculos com nós excluídos.

### 3.2. MongoDB 6.0 (Postagens e Comentários Embutidos)
- **Coleção:** `postagens`.
- **Justificativa:** Redes sociais apresentam alta vazão de escrita (*Write-Heavy*). A modelagem orientada a documentos explora o padrão **Document Embedding**, onde a árvore completa de comentários é armazenada como subdocumentos dentro do próprio post, permitindo recuperá-lo em uma única leitura atômica sem *JOINs* caros.

### 3.3. Redis 7 (Cache em Memória e Gerenciamento de Sessão)
- **Estruturas:** `sessao:{UUID}` (TTL 24h) e `refresh:{UUID}` (TTL 7d).
- **Justificativa:** Reduz a latência de validação de acesso para menos de **1 ms** ($O(1)$ em memória RAM), desonerando o pool JDBC do PostgreSQL a cada requisição HTTP.

---

## 4. Análise Arquitetural: Remoção do Feed Service

Durante a evolução do projeto, foi avaliada a real necessidade de manter um microsserviço independente dedicado exclusivamente ao feed (`feed-service`). A auditoria técnica identificou que mantê-lo constituía um caso evidente de **over-engineering** e um antipadrão de microsserviço anêmico (*nano-service*):

1. **Ausência de Domínio e Banco Próprio:** O feed não possui entidades persistidas próprias; ele é uma consulta/projeção de leitura sobre as postagens (MongoDB) contextualizadas pelo grafo de quem o usuário segue (PostgreSQL). No repositório, o `feed-service` continha apenas uma classe inicializadora vazia.
2. **Eliminação de Saltos de Rede Extras (*Network Hops*):** Em uma chamada ao `feed-service`, o fluxo exigiria:
   $$\text{Cliente} \xrightarrow{\text{HTTP}} \text{Gateway} \xrightarrow{\text{HTTP}} \textbf{feed-service} \xrightarrow{\text{HTTP}} \textbf{post-service} \xrightarrow{\text{TCP}} \text{MongoDB}$$
   Esse salto intermediário aumentava a latência em 15 a 40 ms sob concorrência e causava custos desnecessários de serialização JSON.
3. **Consolidação no `post-service`:** A entrega do feed foi integrada diretamente no `post-service` através da estratégia de **Fan-out on Read** com ordenação cronológica invertida no MongoDB (`criadoEm: -1`). A hidratação de perfis ocorre em lote (*Batch Enrichment* via Feign no `user-profile-service`), garantindo resposta em cerca de 1.2 ms e eliminando o problema de $N+1$ requisições.

A pasta `feed-service`, sua declaração no `pom.xml` pai e as rotas isoladas no Gateway foram formalmente removidas, consolidando as rotas `/posts/**`, `/api/posts/**` e `/api/feed/**` diretamente no `post-service`.

---

## 5. Modelagem de Dados e Regras Críticas no SGBD

### 5.1. Regras de Negócio Implementadas no PostgreSQL
Conforme especificação formal de Banco de Dados II, regras essenciais de integridade e inteligência de dados foram codificadas diretamente no SGBD:
- **Visão `vw_resumo_engajamento_perfis`:** Consolida dados de perfil, seguidores, seguidos, tema escolhido e autenticação em dois fatores em um único SELECT.
- **Visão `vw_ranking_influenciadores`:** Ranqueia perfis mais influentes com a *Window Function* `DENSE_RANK() OVER (ORDER BY COUNT(s.seguidor_id) DESC)`.
- **Stored Procedure `sp_registrar_seguimento`:** Executa a criação de relacionamentos em transação ACID com validação contra auto-seguimento e checagem de existência prévia de nós.
- **Trigger `trg_normaliza_node_id`:** Normaliza qualquer identificador de usuário para conter obrigatoriamente o prefixo `@` antes do INSERT/UPDATE.
- **Trigger `trg_atualiza_perfis_usuarios`:** Atualiza o carimbo de data/hora (`atualizado_em`) no nível do banco, independente da aplicação.

---

## 6. Estudo de Desempenho e Benchmarking (SQL e NoSQL)

### 6.1. MongoDB: Consulta Cronológica do Feed (100.000 Registros)
- **Consulta:** `db.postagens.find({}).sort({ criadoEm: -1 }).limit(20)`
- **Índice Criado:** `db.postagens.createIndex({ criadoEm: -1 })`

| Métrica | Sem Índice (`COLLSCAN`) | Com Índice (`IXSCAN`) | Ganho de Eficiência |
| :--- | :--- | :--- | :--- |
| **Estágio** | `COLLSCAN + SORT` (RAM) | `IXSCAN` | Eliminação do sort em RAM |
| **Documentos Lidos** | 100.000 documentos | 20 documentos | **99.98% menos leituras** |
| **Tempo de Execução** | **285,40 ms** | **1,21 ms** | **~235x mais rápido** |

### 6.2. PostgreSQL: Contagem no Grafo Social (25.000 Vínculos)
- **Consulta:** `EXPLAIN ANALYZE SELECT count(*) FROM seguidores WHERE seguido_id = '...';`

| Métrica | Sem Índice (`Seq Scan`) | Com Índice (`Index Only Scan`) | Ganho de Eficiência |
| :--- | :--- | :--- | :--- |
| **Estágio** | Varredura Sequencial | Acesso exclusivo ao índice B-Tree | Menos blocos carregados |
| **Buffers Compartilhados** | 185 blocos | 2 blocos | **98.9% menos I/O** |
| **Tempo de Execução** | **18,42 ms** | **0,08 ms** | **~230x mais rápido** |

---

## 7. Fluxos Operacionais e Integração Distribuída

1. **Registro (Sign-Up):** Requisição via Gateway $\rightarrow$ `auth-service` persiste credencial com BCrypt $\rightarrow$ Chamada síncrona Feign para `user-profile-service` cria perfil e preferências iniciais $\rightarrow$ Resposta 201 Created.
2. **Autenticação (Sign-In) e Sessão Opaca:** `auth-service` valida credencial no Postgres $\rightarrow$ Emite JWT e grava no Redis `sessao:{uuid}` (TTL 24h) $\rightarrow$ Retorna cookie `HttpOnly` com ID de sessão para o cliente.
3. **Leitura de Feed com Batch Enrichment:** Gateway valida sessão no Redis em $O(1)$ $\rightarrow$ Encaminha com Bearer JWT para `post-service` $\rightarrow$ `post-service` busca 20 posts no MongoDB $\rightarrow$ Dispara única chamada Feign em lote `POST /usuarios/batch` para hidratar nomes/avatares atualizados do Postgres $\rightarrow$ Entrega feed montado.
4. **Exclusão de Conta em Cascata:** `user-profile-service` deleta preferências/seguidores $\rightarrow$ Invoca `post-service` para apagar postagens do autor no MongoDB $\rightarrow$ Invoca `auth-service` para deletar credenciais no Postgres $\rightarrow$ Revoga sessões no Redis.

---

## 8. Histórico e Divisão Empírica de Contribuições (Auditoria Git)

A auditoria autônoma do repositório Git do projeto revelou o histórico detalhado de colaboração entre os dois integrantes, demonstrando uma divisão de trabalho equilibrada e complementar:

### Matriz Geral de Entregas por Autor

| Frente de Atuação | Yasmin Gomes Ventura | Bruno Hollyver Alves dos Mártires |
| :--- | :--- | :--- |
| **Arquitetura de Microsserviços** | Setup dos microsserviços Spring Boot (Gateway, Eureka, Auth, Post) e rotas do Gateway. | Configuração Docker Compose, portas de rede e remoção do `feed-service` redundante. |
| **Banco de Dados Relacional (SQL)** | DDLs 3FN (`auth` e `profile`), Views analíticas, Procedure transacional e Triggers no PostgreSQL. | Modelagem do esquema de preferências e privacidade (1:1 com usuário). |
| **Banco Não-Relacional e Cache** | Coleções MongoDB, índices com `createIndex`, benchmarks NoSQL e especificação Redis. | Refinamento da árvore de comentários (`parentId`), auditoria do gerador de seed de dados. |
| **Integração Distribuída** | Endpoints REST no `user-profile-service` para fornecimento de dados de perfil em lote. | Implementação do cliente OpenFeign (`AuthClient`) para *Batch Enrichment*, eliminando $N+1$. |
| **Frontend (Flutter)** | Modal de busca global (`global_search_modal`), mecânica de Repost, personalização de banner. | Concepção inicial do app, `ApiClient`, controle de sessão/CORS, navegação e tradução para pt-BR. |
| **Negócio e Moderação** | Lógica de relacionamentos de seguidores e validações no PostgreSQL. | Busca mista por `nodeId`, cascata de exclusão distribuída e permissões de perfil ADMIN. |

### 8.1. Detalhamento das Entregas de Yasmin Gomes Ventura
1. **Fundação dos Microsserviços:** Inicialização da estrutura Maven multimodular e setup inicial de dependências do Spring Cloud (commits `3b8f0f7` e `0d4f6b5`).
2. **Serviço de Perfis e Preferências:** Construção do `user-profile-service`, com entidades JPA `PerfilUsuario` e `UsuarioPreferencias`, DTOs de mapeamento e serviços de atualização.
3. **Engenharia de Banco de Dados SQL e NoSQL:** Autoria dos scripts `01_ddl_auth.sql`, `02_ddl_profile.sql`, `03_views_and_triggers.sql`, `04_queries_benchmark.sql`, `01_mongo_indexes.js`, `02_mongo_queries_benchmark.js` e `03_redis_patterns.md` (commit `8307362`).
4. **Mecânica de Repost e Busca no Frontend:** Implementação completa da funcionalidade de republicação de posts (commits `2b643e2`) e modal de busca global (commit `da100be`).
5. **Documentação Arquitetural:** Elaboração dos diagramas em Mermaid e documentação técnica de suporte (commit `5fcca1c`).

### 8.2. Detalhamento das Entregas de Bruno Hollyver Alves dos Mártires
1. **Concepção do Frontend Flutter e Identidade Slow Tech:** Criação da estrutura base do aplicativo, componentes de interface, design retrofuturista anos 2000 e paleta suave (commit `a12b977`).
2. **Camada de Comunicação HTTP e Sessão:** Desenvolvimento do `ApiClient`, tratamento dinâmico de `baseUrl` (Flutter Web / Desktop / Docker) e tratamento de CORS e cookies de sessão.
3. **Resolução de $N+1$ de Rede via OpenFeign:** Implementação da rotina de *Batch Enrichment* no `post-service` via Feign client (`POST /usuarios/batch`), garantindo alta vazão na renderização do feed (commit `6e666be`).
4. **Integração de Busca por Identificador de Nó:** Conexão da pesquisa de usuários e transmissões por `nodeId` (`@usuario`) e nome civil no backend e no frontend (commit `08207d1`).
5. **Localização em Português e Ergonomia:** Tradução integral da plataforma para português brasileiro (`pt-BR`) e refinamento ergonômico dos fluxos de cadastro e login (commit `70513b5`).
6. **Correção de Árvore de Comentários e Carga de Dados:** Correção do encadeamento de respostas subordinadas em comentários (`ComentarioPostagem.java`, `PostagemService.java`) e auditoria corretiva no script PowerShell de povoamento `GerarPovoamento.ps1` (commit `60a663f`).

---

## 9. Conclusão e Considerações Finais

O projeto **Telegrama** comprovou com sucesso a viabilidade de uma arquitetura poliglota para redes sociais calmas (*Slow Tech*). Ao direcionar cada classe de dados ao motor tecnologicamente mais indicado (PostgreSQL para integridade e relacionamentos, MongoDB para documentos e árvores de comentários, e Redis para sessões e cache ultra-rápido), o sistema atingiu latências sub-milissegundo em operações críticas. A remoção criteriosa do microsserviço redundante de feed demonstrou maturidade técnica, simplificando a infraestrutura sem qualquer prejuízo à escalabilidade.

---

## 10. Referências Bibliográficas

1. DATE, C. J. **Introdução a Sistemas de Bancos de Dados**. 8. ed. Rio de Janeiro: Elsevier, 2004.
2. ELMASRI, Ramez; NAVATHE, Shamkant B. **Sistemas de Banco de Dados**. 6. ed. São Paulo: Pearson Addison Wesley, 2011.
3. FOWLER, Martin; SADALAGE, Pramod J. **NoSQL Distilled: A Brief Guide to the Emerging World of Polyglot Persistence**. Boston: Addison-Wesley Professional, 2012.
4. NEWMAN, Sam. **Building Microservices: Designing Fine-Grained Systems**. 2. ed. Sebastopol: O'Reilly Media, 2021.
5. KLEPPMANN, Martin. **Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems**. Sebastopol: O'Reilly Media, 2017.
6. MONGODB INC. **MongoDB Manual: Data Models and Embedded Documents**, 2026.
7. POSTGRESQL GLOBAL DEVELOPMENT GROUP. **PostgreSQL 15 Documentation: Indexes and Performance**, 2026.
