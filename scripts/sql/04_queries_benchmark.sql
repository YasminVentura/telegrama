-- ========================================================
-- PROJETO TELEGRAMA - BANCO DE DADOS II
-- Script: 04_queries_benchmark.sql
-- Banco: PostgreSQL (telegrama_profile)
-- Descrição: Consultas para análise de desempenho e planos de execução (EXPLAIN ANALYZE)
-- ========================================================

-- --------------------------------------------------------
-- CENÁRIO 1: Busca de Perfil por Node ID (Identificador da Rede)
-- --------------------------------------------------------

-- 1.1 Consulta com Índice Ativo (B-Tree Index Scan)
EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT * FROM perfis_usuarios 
WHERE node_id = '@alice_dev';

-- 1.2 Simulação de consulta sem índice (Desativação forçada de Index Scan para teste)
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT * FROM perfis_usuarios 
WHERE node_id = '@alice_dev';

-- Restaura os parâmetros
SET enable_indexscan = ON;
SET enable_bitmapscan = ON;


-- --------------------------------------------------------
-- CENÁRIO 2: Contagem de Seguidores (Grafo de Relações N:M)
-- --------------------------------------------------------

-- 2.1 Consulta com Índice Composto na Chave Estrangeira (Index Only Scan)
EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT count(*) FROM seguidores 
WHERE seguido_id = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';

-- 2.2 Consulta sem índice (Seq Scan completo na tabela com 30k+ linhas)
SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT count(*) FROM seguidores 
WHERE seguido_id = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;


-- --------------------------------------------------------
-- CENÁRIO 3: Consulta Analítica na View de Ranking de Influenciadores
-- --------------------------------------------------------
EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT * FROM vw_ranking_influenciadores 
LIMIT 10;

