
CREATE OR REPLACE VIEW vw_resumo_engajamento_perfis AS
SELECT
    p.id AS usuario_id,
    p.nome,
    p.node_id,
    p.email,
    p.perfil AS role_usuario,
    p.avatar_url,
    p.banner_color,
    COALESCE(pref.theme, 'RETRO_GREEN') AS tema_preferido,
    COALESCE(pref.two_factor_auth, FALSE) AS dois_fatores_ativo,
    COUNT(DISTINCT s_seguidores.id) AS total_seguidores,
    COUNT(DISTINCT s_seguindo.id) AS total_seguindo,
    p.criado_em AS data_cadastro
FROM perfis_usuarios p
LEFT JOIN usuario_preferencias pref ON p.id = pref.usuario_id
LEFT JOIN seguidores s_seguidores ON p.id = s_seguidores.seguido_id
LEFT JOIN seguidores s_seguindo ON p.id = s_seguindo.seguidor_id
GROUP BY p.id, p.nome, p.node_id, p.email, p.perfil, p.avatar_url, p.banner_color, pref.theme, pref.two_factor_auth, p.criado_em;

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

CREATE OR REPLACE PROCEDURE sp_registrar_seguimento(
    IN p_seguidor_id UUID,
    IN p_seguido_id UUID
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_seguidor_id = p_seguido_id THEN
        RAISE EXCEPTION 'Regra de Negócio Violada: Um usuário não pode seguir a si próprio.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM perfis_usuarios WHERE id = p_seguidor_id) THEN
        RAISE EXCEPTION 'Usuário seguidor não encontrado com ID: %', p_seguidor_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM perfis_usuarios WHERE id = p_seguido_id) THEN
        RAISE EXCEPTION 'Usuário alvo não encontrado com ID: %', p_seguido_id;
    END IF;

    INSERT INTO seguidores (id, seguidor_id, seguido_id, criado_em)
    VALUES (uuid_generate_v4(), p_seguidor_id, p_seguido_id, CURRENT_TIMESTAMP)
    ON CONFLICT (seguidor_id, seguido_id) DO NOTHING;
END;
$$;

CREATE OR REPLACE FUNCTION fn_atualizar_timestamp_modificacao()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_atualiza_perfis_usuarios ON perfis_usuarios;
CREATE TRIGGER trg_atualiza_perfis_usuarios
BEFORE UPDATE ON perfis_usuarios
FOR EACH ROW
EXECUTE FUNCTION fn_atualizar_timestamp_modificacao();

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

DROP TRIGGER IF EXISTS trg_normaliza_node_id ON perfis_usuarios;
CREATE TRIGGER trg_normaliza_node_id
BEFORE INSERT OR UPDATE OF node_id ON perfis_usuarios
FOR EACH ROW
EXECUTE FUNCTION fn_normalizar_node_id();
