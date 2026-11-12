-- ========================================================
-- PROJETO TELEGRAMA - BANCO DE DADOS II
-- Script: 02_ddl_profile.sql
-- Banco: PostgreSQL (telegrama_profile)
-- Descrição: Estrutura DDL para perfis, preferências e grafo de seguidores (3FN).
-- ========================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Tabela de Perfis de Usuários
CREATE TABLE IF NOT EXISTS perfis_usuarios (
    id UUID PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    node_id VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    bio VARCHAR(500),
    localizacao VARCHAR(255),
    avatar_url VARCHAR(255) DEFAULT 'lib/assets/images/avatars/avatar_1.webp',
    banner_color VARCHAR(50) DEFAULT '#2E4F3E',
    perfil VARCHAR(50) NOT NULL DEFAULT 'USER',
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_perfis_node_id UNIQUE (node_id),
    CONSTRAINT uk_perfis_email UNIQUE (email),
    CONSTRAINT ck_perfis_role CHECK (perfil IN ('USER', 'ADMIN'))
);

CREATE INDEX IF NOT EXISTS idx_perfis_node_id ON perfis_usuarios(node_id);
CREATE INDEX IF NOT EXISTS idx_perfis_nome ON perfis_usuarios(nome);
CREATE INDEX IF NOT EXISTS idx_perfis_email ON perfis_usuarios(email);

-- 2. Tabela de Preferências de Usuário (Relacionamento 1:1)
CREATE TABLE IF NOT EXISTS usuario_preferencias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL,
    private_frequency_mode BOOLEAN NOT NULL DEFAULT FALSE,
    direct_transmissions BOOLEAN NOT NULL DEFAULT TRUE,
    broadcast_node_activity BOOLEAN NOT NULL DEFAULT TRUE,
    push_transmissions BOOLEAN NOT NULL DEFAULT TRUE,
    acoustic_echos BOOLEAN NOT NULL DEFAULT TRUE,
    zone_broadcast_alerts BOOLEAN NOT NULL DEFAULT FALSE,
    two_factor_auth BOOLEAN NOT NULL DEFAULT FALSE,
    theme VARCHAR(50) NOT NULL DEFAULT 'RETRO_GREEN',
    avatar_url VARCHAR(255) DEFAULT 'lib/assets/images/avatars/avatar_1.webp',
    banner_color VARCHAR(50) DEFAULT '#2E4F3E',
    CONSTRAINT uk_preferencias_usuario_id UNIQUE (usuario_id),
    CONSTRAINT fk_preferencias_usuario FOREIGN KEY (usuario_id) 
        REFERENCES perfis_usuarios(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_preferencias_usuario_id ON usuario_preferencias(usuario_id);

-- 3. Tabela de Seguidores (Grafo de Relacionamentos N:M)
CREATE TABLE IF NOT EXISTS seguidores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seguidor_id UUID NOT NULL,
    seguido_id UUID NOT NULL,
    criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_seguidor_seguido UNIQUE (seguidor_id, seguido_id),
    CONSTRAINT ck_impedir_auto_seguimento CHECK (seguidor_id <> seguido_id),
    CONSTRAINT fk_seguidor FOREIGN KEY (seguidor_id) 
        REFERENCES perfis_usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_seguido FOREIGN KEY (seguido_id) 
        REFERENCES perfis_usuarios(id) ON DELETE CASCADE
);

-- Índices cruciais para a performance de contagem e busca bidirecional do grafo
CREATE INDEX IF NOT EXISTS idx_seguidores_seguidor_id ON seguidores(seguidor_id);
CREATE INDEX IF NOT EXISTS idx_seguidores_seguido_id ON seguidores(seguido_id);
CREATE INDEX IF NOT EXISTS idx_seguidores_composto ON seguidores(seguidor_id, seguido_id);

