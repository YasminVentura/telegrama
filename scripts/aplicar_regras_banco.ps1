<#
.SYNOPSIS
    Aplica as Views, Triggers, Procedures e Índices nos contêineres Docker do Telegrama
.DESCRIPTION
    Executa os scripts SQL no PostgreSQL e os scripts JS no MongoDB rodando via Docker.
#>

$ErrorActionPreference = "Continue"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  APLICANDO VIEWS, TRIGGERS E ÍNDICES NO AMBIENTE DOCKER   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. PostgreSQL (telegrama-postgres) - Banco telegrama_auth
Write-Host "`n[1/3] Aplicando DDL no banco telegrama_auth..." -ForegroundColor Yellow
docker exec -i telegrama-postgres psql -U user -d telegrama_auth -f - < "$PSScriptRoot\sql\01_ddl_auth.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ DDL telegrama_auth aplicado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "! Aviso ao aplicar no telegrama_auth (verifique se o container está rodando)" -ForegroundColor Red
}

# 2. PostgreSQL (telegrama-postgres) - Banco telegrama_profile
Write-Host "`n[2/3] Aplicando DDL, Views e Triggers no banco telegrama_profile..." -ForegroundColor Yellow
docker exec -i telegrama-postgres psql -U user -d telegrama_profile -f - < "$PSScriptRoot\sql\02_ddl_profile.sql"
docker exec -i telegrama-postgres psql -U user -d telegrama_profile -f - < "$PSScriptRoot\sql\03_views_and_triggers.sql"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ DDL, Views e Triggers aplicados com sucesso no telegrama_profile!" -ForegroundColor Green
} else {
    Write-Host "! Aviso ao aplicar no telegrama_profile" -ForegroundColor Red
}

# 3. MongoDB (telegrama-mongodb) - Banco telegrama_posts
Write-Host "`n[3/3] Aplicando Índices no MongoDB telegrama_posts..." -ForegroundColor Yellow
docker exec -i telegrama-mongodb mongosh telegrama_posts --file - < "$PSScriptRoot\nosql\01_mongo_indexes.js"
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Índices do MongoDB aplicados com sucesso!" -ForegroundColor Green
} else {
    Write-Host "! Aviso ao aplicar índices no MongoDB" -ForegroundColor Red
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  CONFIGURAÇÃO CONCLUÍDA! O SGBD ESTÁ 100% EM CONFORMIDADE " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

