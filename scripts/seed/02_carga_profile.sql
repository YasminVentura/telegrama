
BEGIN;

INSERT INTO perfis_usuarios (id, nome, node_id, email, bio, localizacao, avatar_url, banner_color, perfil, criado_em, atualizado_em) VALUES
('491bece0-9a67-4f6f-8a49-dfd9f04965ab', 'Arthur Nogueira 1', '@user_1', 'user_1@telegrama.zone', 'Engenheiro de software focado em microsserviços e bancos poliglotas.', 'Rio de Janeiro, RJ', 'lib/assets/images/avatars/avatar_3.webp', '#1F3A4B', 'ADMIN', '2026-07-06 09:58:16', '2026-07-06 09:58:16'),
('9981414a-ade0-4637-be58-37d79c6155e5', 'Fernanda Lima 2', '@user_2', 'user_2@telegrama.zone', 'Apenas mais um nó nesta rede descentralizada.', 'Belo Horizonte, MG', 'lib/assets/images/avatars/avatar_2.webp', '#2A2A2A', 'USER', '2026-09-05 03:54:16', '2026-09-05 03:54:16'),
('8f45cb8d-40d8-47c1-b7ae-754eeaea09d8', 'Rafaela Gomes 3', '@user_3', 'user_3@telegrama.zone', 'Explorando frequências e construindo o futuro da web.', 'Florianópolis, SC', 'lib/assets/images/avatars/avatar_3.webp', '#4F3A2E', 'USER', '2026-10-27 14:35:16', '2026-10-27 14:35:16'),
('6d866733-7d57-49da-9013-ecc413e3ba5a', 'Enzo Pereira 4', '@user_4', 'user_4@telegrama.zone', 'Arquiteto de sistemas distribuídos | Java & MongoDB lover.', 'São Paulo, SP', 'lib/assets/images/avatars/avatar_4.webp', '#1F3A4B', 'USER', '2026-07-12 10:03:16', '2026-07-12 10:03:16'),
('e3bc2f8c-8ec1-4079-a0f4-b7b52f2ba95a', 'Fernanda Lima 5', '@user_5', 'user_5@telegrama.zone', 'Explorando frequências e construindo o futuro da web.', 'Curitiba, PR', 'lib/assets/images/avatars/avatar_3.webp', '#047857', 'USER', '2026-08-09 16:59:16', '2026-08-09 16:59:16');

INSERT INTO usuario_preferencias (id, usuario_id, private_frequency_mode, direct_transmissions, broadcast_node_activity, push_transmissions, acoustic_echos, zone_broadcast_alerts, two_factor_auth, theme, avatar_url, banner_color) VALUES
('70085bde-b489-4543-93f5-d4beae71abc6', '491bece0-9a67-4f6f-8a49-dfd9f04965ab', FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, 'CYBERPUNK_DARK', 'lib/assets/images/avatars/avatar_3.webp', '#1F3A4B'),
('ebad1038-3600-45a0-8294-286b9a0ec09b', '9981414a-ade0-4637-be58-37d79c6155e5', FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, 'CYBERPUNK_DARK', 'lib/assets/images/avatars/avatar_2.webp', '#2A2A2A'),
('1e50903f-016c-47b1-9d4b-e67dc25278a2', '8f45cb8d-40d8-47c1-b7ae-754eeaea09d8', FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, 'RETRO_GREEN', 'lib/assets/images/avatars/avatar_3.webp', '#4F3A2E'),
('e2a546ff-9ba6-44ff-83e8-d9145980414b', '6d866733-7d57-49da-9013-ecc413e3ba5a', FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, 'CREAM_ESPRESSO', 'lib/assets/images/avatars/avatar_4.webp', '#1F3A4B'),
('e38121a6-c6fb-4859-ab5f-c7cd06990196', 'e3bc2f8c-8ec1-4079-a0f4-b7b52f2ba95a', FALSE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE, 'RETRO_GREEN', 'lib/assets/images/avatars/avatar_3.webp', '#047857');

INSERT INTO seguidores (id, seguidor_id, seguido_id, criado_em) VALUES
('403bb01b-df1d-4a11-877c-09c7ea56107c', '6d866733-7d57-49da-9013-ecc413e3ba5a', '9981414a-ade0-4637-be58-37d79c6155e5', '2026-10-29 21:40:16'),
('a4aa7bd5-f845-438e-a746-c6ee8d51f239', '491bece0-9a67-4f6f-8a49-dfd9f04965ab', '9981414a-ade0-4637-be58-37d79c6155e5', '2026-09-04 21:40:16'),
('b6251c2d-a0e3-40e2-85f7-268e686826ba', '9981414a-ade0-4637-be58-37d79c6155e5', '6d866733-7d57-49da-9013-ecc413e3ba5a', '2026-10-30 21:40:16'),
('1b8105d5-7339-4944-ab4e-ab5e4f938cdd', '491bece0-9a67-4f6f-8a49-dfd9f04965ab', '6d866733-7d57-49da-9013-ecc413e3ba5a', '2026-09-27 21:40:16'),
('e0be9471-809f-4ab5-bc6b-6a0f6e5e8eb4', '491bece0-9a67-4f6f-8a49-dfd9f04965ab', '8f45cb8d-40d8-47c1-b7ae-754eeaea09d8', '2026-09-10 21:40:16');
COMMIT;
