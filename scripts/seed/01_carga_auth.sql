
BEGIN;
INSERT INTO usuarios (id, nome, node_id, email, senha, termos_aceitos, perfil, criado_em, atualizado_em) VALUES
('491bece0-9a67-4f6f-8a49-dfd9f04965ab', 'Arthur Nogueira 1', '@user_1', 'user_1@telegrama.zone', '$2a$10$eACCYoNOHEqgkVE8aWnATO3qE7WODErGQzL6GZ8lq0m8o6C7xS4rS', TRUE, 'ADMIN', '2026-07-06 09:58:16', '2026-07-06 09:58:16'),
('9981414a-ade0-4637-be58-37d79c6155e5', 'Fernanda Lima 2', '@user_2', 'user_2@telegrama.zone', '$2a$10$eACCYoNOHEqgkVE8aWnATO3qE7WODErGQzL6GZ8lq0m8o6C7xS4rS', TRUE, 'USER', '2026-09-05 03:54:16', '2026-09-05 03:54:16'),
('8f45cb8d-40d8-47c1-b7ae-754eeaea09d8', 'Rafaela Gomes 3', '@user_3', 'user_3@telegrama.zone', '$2a$10$eACCYoNOHEqgkVE8aWnATO3qE7WODErGQzL6GZ8lq0m8o6C7xS4rS', TRUE, 'USER', '2026-10-27 14:35:16', '2026-10-27 14:35:16'),
('6d866733-7d57-49da-9013-ecc413e3ba5a', 'Enzo Pereira 4', '@user_4', 'user_4@telegrama.zone', '$2a$10$eACCYoNOHEqgkVE8aWnATO3qE7WODErGQzL6GZ8lq0m8o6C7xS4rS', TRUE, 'USER', '2026-07-12 10:03:16', '2026-07-12 10:03:16'),
('e3bc2f8c-8ec1-4079-a0f4-b7b52f2ba95a', 'Fernanda Lima 5', '@user_5', 'user_5@telegrama.zone', '$2a$10$eACCYoNOHEqgkVE8aWnATO3qE7WODErGQzL6GZ8lq0m8o6C7xS4rS', TRUE, 'USER', '2026-08-09 16:59:16', '2026-08-09 16:59:16');
COMMIT;
