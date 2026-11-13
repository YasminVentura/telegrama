
const dbInstance = db.getSiblingDB("telegrama_posts");

print("\n========================================================");
print("BENCHMARK 1: Paginação do Feed (Top 20 posts recentes)");
print("========================================================");

const statsFeedComIndice = dbInstance.postagens.find({})
    .sort({ criadoEm: -1 })
    .limit(20)
    .explain("executionStats");

print("Estágio do plano: " + statsFeedComIndice.executionStats.executionStages.stage);
print("Documentos examinados: " + statsFeedComIndice.executionStats.totalDocsExamined);
print("Chaves de índice examinadas: " + statsFeedComIndice.executionStats.totalKeysExamined);
print("Tempo de execução (ms): " + statsFeedComIndice.executionStats.executionTimeMillis);

const statsFeedSemIndice = dbInstance.postagens.find({})
    .sort({ criadoEm: -1 })
    .hint({ $natural: 1 })
    .limit(20)
    .explain("executionStats");

print("\n--- Simulação Forçando COLLSCAN (Sem Índice) ---");
print("Documentos examinados (Scan completo): " + statsFeedSemIndice.executionStats.totalDocsExamined);
print("Tempo de execução (ms): " + statsFeedSemIndice.executionStats.executionTimeMillis);

print("\n========================================================");
print("BENCHMARK 2: Filtrar posts de um autor (@alice_dev)");
print("========================================================");

const statsAutorComIndice = dbInstance.postagens.find({ autorNodeId: "@alice_dev" })
    .sort({ criadoEm: -1 })
    .limit(10)
    .explain("executionStats");

print("Estágio: " + statsAutorComIndice.executionStats.executionStages.stage);
print("Tempo de execução (ms): " + statsAutorComIndice.executionStats.executionTimeMillis);

print("\n========================================================");
print("BENCHMARK 3: Busca Textual por Palavra-Chave ('tecnologia')");
print("========================================================");

const statsTextSearch = dbInstance.postagens.find({ $text: { $search: "tecnologia" } })
    .limit(10)
    .explain("executionStats");

print("Estágio: " + statsTextSearch.executionStats.executionStages.stage);
print("Documentos retornados: " + statsTextSearch.executionStats.nReturned);
print("Tempo de execução (ms): " + statsTextSearch.executionStats.executionTimeMillis);
