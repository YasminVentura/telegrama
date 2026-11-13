
EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT * FROM perfis_usuarios
WHERE node_id = '@alice_dev';

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT * FROM perfis_usuarios
WHERE node_id = '@alice_dev';

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT count(*) FROM seguidores
WHERE seguido_id = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';

SET enable_indexscan = OFF;
SET enable_bitmapscan = OFF;

EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT count(*) FROM seguidores
WHERE seguido_id = 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d';

SET enable_indexscan = ON;
SET enable_bitmapscan = ON;

EXPLAIN (ANALYZE, BUFFERS, COSTS)
SELECT * FROM vw_ranking_influenciadores
LIMIT 10;
