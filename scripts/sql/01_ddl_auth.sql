-- ========================================================
-- PROJETO TELEGRAMA - BANCO DE DADOS II
-- Script: 01_ddl_auth.sql
-- Banco: PostgreSQL (telegrama_auth)
-- Descrição: Estrutura DDL para autenticação, controle de acesso e auditoria.
-- ========================================================

-- Criação da extensão para geração nativa de UUID (caso necessário)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabela de Usuários / Credenciais Core (Normalizada 3FN)
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    node_id VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    senha VARCHAR(255) NOT NULL,
    termos_aceitos BOOLEAN NOT NULL DEFAULT FALSE,
    perfil VARCHAR(50) NOT NULL DEFAULT 'USER',
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_usuarios_node_id UNIQUE (node_id),
    CONSTRAINT uk_usuarios_email UNIQUE (email),
    CONSTRAINT ck_usuarios_perfil CHECK (perfil IN ('USER', 'ADMIN'))
);

-- 2. Índices para Otimização de Busca e Autenticação
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_node_id ON usuarios(node_id);
CREATE INDEX IF NOT EXISTS idx_usuarios_criado_em ON usuarios(criado_em DESC);

-- 3. Tabela de Auditoria de Acessos / Log Transacional
CREATE TABLE IF NOT EXISTS log_auditoria_autenticacao (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID,
    acao VARCHAR(100) NOT NULL,
    ip_origem VARCHAR(45),
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sucesso BOOLEAN NOT NULL DEFAULT TRUE,
    detalhes TEXT,
    CONSTRAINT fk_auditoria_usuario FOREIGN KEY (usuario_id) 
        REFERENCES usuarios(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_auditoria_data_hora ON log_auditoria_autenticacao(data_hora DESC);

