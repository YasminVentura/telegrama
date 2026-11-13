
const dbName = "telegrama_posts";
const dbInstance = db.getSiblingDB(dbName);

print("=== Criando Índices na Coleção 'postagens' ===");

dbInstance.postagens.createIndex(
    { criadoEm: -1 },
    { name: "idx_postagens_feed_cronologico" }
);

dbInstance.postagens.createIndex(
    { autorNodeId: 1, criadoEm: -1 },
    { name: "idx_postagens_autor_cronologico" }
);

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

dbInstance.postagens.createIndex(
    { conteudo: "text" },
    {
        name: "idx_postagens_busca_textual",
        default_language: "portuguese"
    }
);

print("=== Índices criados com sucesso! Lista de índices ativos: ===");
printjson(dbInstance.postagens.getIndexes());
