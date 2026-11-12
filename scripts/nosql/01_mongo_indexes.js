// ========================================================
// PROJETO TELEGRAMA - BANCO DE DADOS II
// Script: 01_mongo_indexes.js
// Banco: MongoDB (telegrama_posts)
// Coleção: postagens
// Descrição: Criação de índices estratégicos para suportar alta vazão e paginação do feed.
// Execução: mongosh telegrama_posts < 01_mongo_indexes.js
// ========================================================

const dbName = "telegrama_posts";
const dbInstance = db.getSiblingDB(dbName);

print("=== Criando Índices na Coleção 'postagens' ===");

// 1. Índice para Paginação Cronológica do Feed Principal (findAllByOrderByCriadoEmDesc)
// Elimina necessidade de SORT em memória RAM para os 100k documentos
dbInstance.postagens.createIndex(
    { criadoEm: -1 },
    { name: "idx_postagens_feed_cronologico" }
);

// 2. Índice Composto para Perfil de Autor + Timeline Própria
dbInstance.postagens.createIndex(
    { autorNodeId: 1, criadoEm: -1 },
    { name: "idx_postagens_autor_cronologico" }
);

// 3. Índices Multivalorados (Multikey Indexes) para Arrays de Interações
// Otimiza consultas como findByCurtidasInOrderByCriadoEmDesc
dbInstance.postagens.createIndex(
    { curtidas: 1, criadoEm: -1 },
    { name: "idx_postagens_curtidas_cronologico" }
);

dbInstance.postagens.createIndex(
    { salvos: 1, criadoEm: -1 },
    { name: "idx_postagens_salvos_cronologico" }
);

dbInstance.postagens.createIndex(
    { reposts: 1, criadoEm: -1 },
    { name: "idx_postagens_reposts_cronologico" }
);

// 4. Índice Textual para Busca Semântica de Conteúdo (Search)
dbInstance.postagens.createIndex(
    { conteudo: "text" },
    { 
        name: "idx_postagens_busca_textual",
        default_language: "portuguese"
    }
);

print("=== Índices criados com sucesso! Lista de índices ativos: ===");
printjson(dbInstance.postagens.getIndexes());

