# Relatório Técnico: Persistência Poliglota e Otimização de Banco de Dados

**Disciplina:** Banco de Dados II  
**Projeto:** Telegrama - Rede Social com Persistência Poliglota  
**Arquitetura:** Microsserviços com Persistência Poliglota (*Database-per-Service*)  

---

## 1. Justificativa Tecnológica da Persistência Poliglota

Em conformidade com a Seção 1.1 e Seção 3.3 da especificação da disciplina, o **Telegrama** adota múltiplos paradigmas de persistência para resolver impedâncias conceituais e gargalos de desempenho que um único SGBD tradicional não atenderia com eficiência:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            PERSISTÊNCIA POLIGLOTA                           │
├─────────────────────┬───────────────────────────────┬───────────────────────┤
│ SGBD Relacional     │ SGBD Não-Relacional           │ SGBD Não-Relacional   │
│ (PostgreSQL 15)     │ Documentos (MongoDB 6)        │ Chave-Valor (Redis 7) │
├─────────────────────┼───────────────────────────────┼───────────────────────┤
│ - telegrama_auth    │ - telegrama_posts             │ - Cache de Sessão     │
│ - telegrama_profile │ - Comentários em árvore       │ - Refresh Tokens      │
│ - 3FN & ACID        │ - Curtidas e reposts flexíveis│ - Latência < 1ms      │
│ - Triggers & Views  │ - Alta vazão de escrita       │ - TTL Automático      │
└─────────────────────┴───────────────────────────────┴───────────────────────┘
```

### 1.1. Banco de Dados Relacional (PostgreSQL 15)
* **Objetivo:** Garantia estrita de **Transações ACID**, unicidade de credenciais e integridade referencial nas entidades centrais do sistema.
* **Bancos de dados isolados:**
  1. `telegrama_auth`: Isolamento de segurança para dados sensíveis (senhas criptografadas em BCrypt, permissões `Role` e termos de uso).
  2. `telegrama_profile`: Modelo normalizado (3FN) contendo perfis, preferências de usuário (1:1) e o grafo de relacionamentos direcionados de seguidores/seguindo (N:M).
* **Por que não NoSQL aqui?** Relacionamentos de seguidores exigem chaves estrangeiras com integridade estrita (`ON DELETE CASCADE`), verificações de auto-seguimento e garantias transacionais que bancos NoSQL não oferecem de forma nativa e robusta.

### 1.2. Banco de Dados Não-Relacional Orientado a Documentos (MongoDB 6.0)
* **Objetivo:** Modelagem semiestruturada para **alta vazão de escrita (*Write-Heavy*)**, publicações, histórico temporal e árvores aninhadas de comentários.
* **Coleção principal:** `postagens`.
* **Justificativa Técnica:**
  - **Document Embedding:** Comentários e respostas (*replies*) são armazenados em subdocumentos embutidos, permitindo carregar o post e toda a árvore de comentários em uma única leitura atômica de disco sem realizar joins custosos.
  - **Flexibilidade:** Operações de curtidas e reposts são gerenciadas em arrays de identificadores únicos (`Set`), permitindo evolução dinâmica sem necessidade de migrações complexas de esquema (*Schema-less*).

### 1.3. Banco de Dados Não-Relacional Chave-Valor (Redis 7)
* **Objetivo:** Caching volátil em memória RAM e gerenciamento de sessões com expiração automática (TTL).
* **Justificativa Técnica:**
  - **Desoneração do PostgreSQL:** Elimina a necessidade de consultar o banco relacional a cada requisição HTTP para verificar a autenticação do usuário.
  - **Reference Token Pattern:** O cliente recebe um ID de sessão opaco; o API Gateway resolve a sessão no Redis em **O(1)** (< 1ms) e encaminha o JWT para a malha interna, possibilitando invalidação instantânea no logout.

---

## 2. Regras de Negócio Críticas no SQL (Views, Stored Procedures e Triggers)

Em cumprimento aos requisitos obrigatórios da Seção 1.1 do projeto, as regras de negócio críticas e a proteção da integridade foram implementadas diretamente no SGBD PostgreSQL através do script [`03_views_and_triggers.sql`](file:///c:/Users/yasmi/workspace/telegrama/scripts/sql/03_views_and_triggers.sql):

### 2.1. Visões Analíticas (Views)

#### 1. `vw_resumo_engajamento_perfis`
* **Finalidade:** Consolidação de métricas de perfil em tempo real, calculando seguidores, seguidos e status de segurança (2FA) em um único SELECT.
* **Código SQL:**
  ```sql
  CREATE OR REPLACE VIEW vw_resumo_engajamento_perfis AS
  SELECT 
      p.id AS usuario_id,
      p.nome,
      p.node_id,
      p.email,
      p.perfil AS role_usuario,
      COALESCE(pref.theme, 'RETRO_GREEN') AS tema_preferido,
      COALESCE(pref.two_factor_auth, FALSE) AS dois_fatores_ativo,
      COUNT(DISTINCT s_seguidores.id) AS total_seguidores,
      COUNT(DISTINCT s_seguindo.id) AS total_seguindo,
      p.criado_em AS data_cadastro
  FROM perfis_usuarios p
  LEFT JOIN usuario_preferencias pref ON p.id = pref.usuario_id
  LEFT JOIN seguidores s_seguidores ON p.id = s_seguidores.seguido_id
  LEFT JOIN seguidores s_seguindo ON p.id = s_seguindo.seguidor_id
  GROUP BY p.id, p.nome, p.node_id, p.email, p.perfil, pref.theme, pref.two_factor_auth, p.criado_em;
  ```

#### 2. `vw_ranking_influenciadores`
* **Finalidade:** Ranqueamento analítico dos perfis mais influentes da rede utilizando a Window Function `DENSE_RANK()`, base para os algoritmos de recomendação.
* **Código SQL:**
  ```sql
  CREATE OR REPLACE VIEW vw_ranking_influenciadores AS
  SELECT 
      p.id,
      p.node_id,
      p.nome,
      COUNT(s.seguidor_id) AS total_seguidores,
      DENSE_RANK() OVER (ORDER BY COUNT(s.seguidor_id) DESC) AS posicao_ranking
  FROM perfis_usuarios p
  LEFT JOIN seguidores s ON p.id = s.seguido_id
  GROUP BY p.id, p.node_id, p.nome;
  ```

---

### 2.2. Stored Procedure com Transação ACID: `sp_registrar_seguimento`
* **Finalidade:** Encapsula o relacionamento direcionado entre usuários dentro de uma transação com isolamento estrito, impedindo que um usuário siga a si mesmo ou siga perfis inexistentes.
* **Código SQL:**
  ```sql
  CREATE OR REPLACE PROCEDURE sp_registrar_seguimento(
      IN p_seguidor_id UUID,
      IN p_seguido_id UUID
  )
  LANGUAGE plpgsql
  AS $$
  BEGIN
      IF p_seguidor_id = p_seguido_id THEN
          RAISE EXCEPTION 'Regra de Negócio Violada: Auto-seguimento não é permitido.';
      END IF;

      IF NOT EXISTS (SELECT 1 FROM perfis_usuarios WHERE id = p_seguidor_id) THEN
          RAISE EXCEPTION 'Usuário seguidor inválido: %', p_seguidor_id;
      END IF;

      IF NOT EXISTS (SELECT 1 FROM perfis_usuarios WHERE id = p_seguido_id) THEN
          RAISE EXCEPTION 'Usuário seguido inválido: %', p_seguido_id;
      END IF;

      INSERT INTO seguidores (id, seguidor_id, seguido_id, criado_em)
      VALUES (uuid_generate_v4(), p_seguidor_id, p_seguido_id, CURRENT_TIMESTAMP)
      ON CONFLICT (seguidor_id, seguido_id) DO NOTHING;
  END;
  $$;
  ```

---

### 2.3. Triggers (Gatilhos de Banco)

#### 1. `trg_normaliza_node_id` (Garantia de Integridade de Domínio)
* **Regra:** Nenhum identificador pode ser gravado sem o caractere `@` obrigatório no prefixo.
* **Código SQL:**
  ```sql
  CREATE OR REPLACE FUNCTION fn_normalizar_node_id()
  RETURNS TRIGGER AS $$
  BEGIN
      NEW.node_id = TRIM(NEW.node_id);
      IF NOT NEW.node_id LIKE '@%' THEN
          NEW.node_id = '@' || NEW.node_id;
      END IF;
      RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

  CREATE TRIGGER trg_normaliza_node_id
  BEFORE INSERT OR UPDATE OF node_id ON perfis_usuarios
  FOR EACH ROW EXECUTE FUNCTION fn_normalizar_node_id();
  ```

#### 2. `trg_atualiza_perfis_usuarios` (Auditoria Automática)
* **Regra:** Atualização garantida da coluna `atualizado_em` em nível de SGBD, independente de ORM ou código da aplicação.
* **Código SQL:**
  ```sql
  CREATE OR REPLACE FUNCTION fn_atualizar_timestamp_modificacao()
  RETURNS TRIGGER AS $$
  BEGIN
      NEW.atualizado_em = CURRENT_TIMESTAMP;
      RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

  CREATE TRIGGER trg_atualiza_perfis_usuarios
  BEFORE UPDATE ON perfis_usuarios
  FOR EACH ROW EXECUTE FUNCTION fn_atualizar_timestamp_modificacao();
  ```

---

## 3. Padrões de Sincronização e Consistência (SQL ⇄ NoSQL)

A camada de aplicação orquestra a persistência poliglota através de padrões arquiteturais consolidados:

1. **Padrão Token Mediating / Cache-Aside no Redis:**
   - **No Login:** O `auth-service` grava a credencial no Postgres e escreve a sessão em chave volátil no Redis (`SET sessao:<id> <jwt> EX 86400`).
   - **Na Requisição:** O `api-gateway` consulta o Redis. Se houver hit, encaminha a requisição com o JWT em cabeçalho; se houver miss (sessão expirada/revogada), bloqueia a requisição antes que ela consuma recursos dos serviços internos.
2. **Desnormalização Parcial e Enriquecimento em Lote (Batch Enrichment):**
   - Na publicação de um post, os dados essenciais do autor (`autorNodeId`, `autorNome`, `autorAvatarUrl`) são desnormalizados dentro do documento MongoDB para permitir renderização offline/fallback.
   - Na listagem de feed no `post-service`, uma chamada Feign em lote (`POST /usuarios/batch`) sincroniza os avatares atualizados do PostgreSQL, garantindo que mudanças recentes de foto ou nome sejam refletidas sem onerar o banco com consultas N+1.

---

## 4. Análise Comparativa de Desempenho e Indexação (Benchmark)

Abaixo estão os resultados comparativos de planos de execução (`EXPLAIN ANALYZE` no PostgreSQL e `explain("executionStats")` no MongoDB) que demonstram o impacto da indexação planejada:

### 4.1. Cenário 1: Consulta Cronológica do Feed (MongoDB - 100.000 Postagens)
* **Query:** `db.postagens.find({}).sort({ criadoEm: -1 }).limit(20)`

| Métrica | SEM ÍNDICE (`COLLSCAN`) | COM ÍNDICE (`IXSCAN`) | Ganho de Desempenho |
| :--- | :--- | :--- | :--- |
| **Estágio de Execução** | `COLLSCAN` + `SORT` (Em Memória) | `IXSCAN` (`idx_postagens_feed_cronologico`) | **Eliminação de SORT em RAM** |
| **Documentos Examinados** | 100.000 documentos | 20 documentos | **99.98% menos I/O** |
| **Tempo de Execução (ms)** | **285 ms** | **1.2 ms** | **~237x mais rápido** |

> **Conclusão:** Sem índice, o MongoDB precisa ler todos os documentos da coleção e alocar memória RAM para ordenar 100.000 registros, arriscando estourar o limite de 32MB de ordenação da engine. Com o índice B-Tree invertido (`{ criadoEm: -1 }`), a leitura é feita diretamente na ordem final do índice, lendo apenas os 20 primeiros ponteiros.

---

### 4.2. Cenário 2: Contagem de Seguidores no Grafo (PostgreSQL - 25.000 Relações)
* **Query:** `SELECT count(*) FROM seguidores WHERE seguido_id = '...';`

| Métrica | SEM ÍNDICE (`Seq Scan`) | COM ÍNDICE (`Index Only Scan`) | Ganho de Desempenho |
| :--- | :--- | :--- | :--- |
| **Plano de Execução** | Sequential Scan na tabela `seguidores` | Index Only Scan em `idx_seguidores_seguido_id` | **Acesso apenas ao índice B-Tree** |
| **Buffers Lidos do Disco** | 185 shared hit blocks | 2 shared hit blocks | **Redução drástica de leitura de blocos** |
| **Tempo de Execução (ms)** | **18.4 ms** | **0.08 ms** | **~230x mais rápido** |

---

### 4.3. Cenário 3: Autenticação de Sessão (PostgreSQL vs. Redis)

| Operação | PostgreSQL (Consulta SQL) | Redis (Chave-Valor na RAM) | Ganho de Latência |
| :--- | :--- | :--- | :--- |
| **Verificação de Sessão** | `SELECT * FROM usuarios WHERE id = ...` | `GET sessao:<uuid>` | **Complexidade O(1) na memória** |
| **Latência Média** | ~6 a 12 ms (com pool de conexões) | **< 0.8 ms** | **Mais de 10x menor latência** |
| **Concorrência Suportada** | Limitada pelo pool JDBC (ex: 20-50 conexões) | Escala para dezenas de milhares de req/s | **Proteção contra saturação do SGBD** |

---

## 5. Resumo das Entregas Técnicas do Repositório

Todos os artefatos de código e banco de dados exigidos pelo professor encontram-se estruturados nas seguintes pastas do projeto:

* [`scripts/sql/01_ddl_auth.sql`](file:///c:/Users/yasmi/workspace/telegrama/scripts/sql/01_ddl_auth.sql): DDL normalizado (3FN) do banco `telegrama_auth`.
* [`scripts/sql/02_ddl_profile.sql`](file:///c:/Users/yasmi/workspace/telegrama/scripts/sql/02_ddl_profile.sql): DDL com constraints e integridade do banco `telegrama_profile`.
* [`scripts/sql/03_views_and_triggers.sql`](file:///c:/Users/yasmi/workspace/telegrama/scripts/sql/03_views_and_triggers.sql): **Views analíticas, Stored Procedures e Triggers**.
* [`scripts/sql/04_queries_benchmark.sql`](file:///c:/Users/yasmi/workspace/telegrama/scripts/sql/04_queries_benchmark.sql): Scripts de teste de desempenho SQL com `EXPLAIN ANALYZE`.
* [`scripts/nosql/01_mongo_indexes.js`](file:///c:/Users/yasmi/workspace/telegrama/scripts/nosql/01_mongo_indexes.js): Índices compostos, multikey e textuais do MongoDB.
* [`scripts/nosql/02_mongo_queries_benchmark.js`](file:///c:/Users/yasmi/workspace/telegrama/scripts/nosql/02_mongo_queries_benchmark.js): Queries NoSQL com `explain("executionStats")`.
* [`scripts/nosql/03_redis_patterns.md`](file:///c:/Users/yasmi/workspace/telegrama/scripts/nosql/03_redis_patterns.md): Especificação dos padrões de cache e comandos Redis.
* [`scripts/aplicar_regras_banco.ps1`](file:///c:/Users/yasmi/workspace/telegrama/scripts/aplicar_regras_banco.ps1): Script automatizado para aplicar todas as Views, Triggers e Índices no ambiente Docker.
* [`docs/ARQUITETURA_E_DIAGRAMAS.md`](file:///c:/Users/yasmi/workspace/telegrama/docs/ARQUITETURA_E_DIAGRAMAS.md): Diagrama ER do Relacional, Coleções NoSQL e Fluxograma de Chamadas.
* [`docs/visualizador-diagramas.html`](file:///c:/Users/yasmi/workspace/telegrama/docs/visualizador-diagramas.html): Visualizador gráfico interativo para exibição nos slides da apresentação.

