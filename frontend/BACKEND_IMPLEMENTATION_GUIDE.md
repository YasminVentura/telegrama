# Telegrama Backend Implementation Guide

This document provides the definitive implementation architecture for the Telegrama platform's backend. Since the frontend repository layer has been decoupled, it can consume either a traditional REST API or integrate directly with a Backend-as-a-Service like Supabase.

Below you will find the two recommended paths for integrating the data layer you just saw in `lib/data/repositories/`.

---

## Option A: Traditional REST Architecture
*Recommended Stack: Node.js (Fastify/Express) ou Python (FastAPI)*

### 1. Estrutura de Rotas e Endpoints

**Auth & Users**
*   `POST /api/v1/auth/login` - Autenticação e retorno de JWT.
*   `POST /api/v1/auth/register` - Criação de conta.
*   `GET /api/v1/users/me` - Retorna os dados do usuário atualizado, incluindo contagens.
*   `PATCH /api/v1/users/me` - Atualiza bio, location, display_name.
*   `POST /api/v1/users/:id/follow` - Segue um usuário.
*   `DELETE /api/v1/users/:id/follow` - Deixa de seguir um usuário.

**Posts (Feed) & Comments**
*   `GET /api/v1/posts?page=1&limit=10` - Feed global com paginação.
*   `POST /api/v1/posts` - Criação de nova postagem.
*   `POST /api/v1/posts/:id/like` - Curte/Descurte uma publicação.
*   `POST /api/v1/posts/:id/repost` - Reposta uma publicação.
*   `GET /api/v1/posts/:id/comments` - Lista os comentários de um post (Thread view).
*   `POST /api/v1/posts/:id/comments` - Cria um novo comentário respondendo ao post.

**Zones**
*   `GET /api/v1/zones` - Lista de zonas exploráveis (suporta query `?category=` e `?q=`).
*   `GET /api/v1/zones/:id` - Detalhes da zona.
*   `POST /api/v1/zones/:id/join` - Entrar em uma zona.
*   `GET /api/v1/zones/:id/posts` - Feed isolado de publicações de uma zona específica.

**Chats**
*   `GET /api/v1/chats` - Lista de conversas ativas.
*   `GET /api/v1/chats/:id/messages` - Mensagens de uma conversa (paginado).
*   `POST /api/v1/chats/:id/messages` - Envio de mensagem.
*   `PATCH /api/v1/chats/:id/read` - Marca o chat como lido.

**Search**
*   `GET /api/v1/search?q={query}` - Busca cruzada agregando posts, usuários e zonas.

### 2. Exemplo de Código (Node.js / Fastify)

Exemplo de uma rota de criação de post protegida por token JWT:

```javascript
// routes/posts.js
export default async function postRoutes(fastify, options) {
  // Hook de validação JWT
  fastify.addHook('onRequest', async (request, reply) => {
    try {
      await request.jwtVerify()
    } catch (err) {
      reply.send(err)
    }
  })

  // Criar postagem
  fastify.post('/', async (request, reply) => {
    const { content, imageUrl, frequencyTag } = request.body;
    const userId = request.user.id;

    const result = await fastify.pg.query(
      `INSERT INTO posts (user_id, content, image_url, frequency_tag) 
       VALUES ($1, $2, $3, $4) RETURNING *`,
      [userId, content, imageUrl, frequencyTag]
    );

    reply.code(201).send(result.rows[0]);
  });
  
  // Listar Zonas
  fastify.get('/zones', async (request, reply) => {
    const result = await fastify.pg.query('SELECT * FROM zones ORDER BY created_at DESC LIMIT 20');
    reply.send(result.rows);
  });
}
```

---

## Option B: Guia Prático com Supabase (Recomendado)
*O Supabase lida com Banco de Dados, Autenticação, Realtime e Storage (BaaS).*

### 1. Schema SQL do Banco de Dados PostgreSQL

Execute este script no SQL Editor do Supabase:

```sql
-- Profiles
CREATE TABLE profiles (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  display_name TEXT,
  handle TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  location TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Follows
CREATE TABLE follows (
  follower_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  following_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()),
  PRIMARY KEY (follower_id, following_id)
);

-- Zones
CREATE TABLE zones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  tag TEXT NOT NULL,
  description TEXT,
  stats TEXT,
  image_url TEXT,
  color TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Posts
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  zone_id UUID REFERENCES zones(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  frequency_tag TEXT,
  likes_count INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Comments (Threads)
CREATE TABLE comments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

-- Function to update comments_count on posts table
CREATE OR REPLACE FUNCTION update_comments_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE posts SET comments_count = comments_count + 1 WHERE id = NEW.post_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE posts SET comments_count = comments_count - 1 WHERE id = OLD.post_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER comments_count_trigger
AFTER INSERT OR DELETE ON comments
FOR EACH ROW EXECUTE FUNCTION update_comments_count();

-- Chats / Messages
CREATE TABLE chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);

CREATE TABLE chat_participants (
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  PRIMARY KEY (chat_id, user_id)
);

CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID REFERENCES chats(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW())
);
```

### 2. Políticas de Segurança (Row Level Security - RLS)

Para garantir que apenas os donos possam deletar seus posts e que mensagens privadas não vazem:

```sql
-- Ativar RLS nas tabelas
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Posts e Comentários são públicos para leitura
CREATE POLICY "Posts are viewable by everyone." 
ON posts FOR SELECT USING (true);

CREATE POLICY "Comments are viewable by everyone." 
ON comments FOR SELECT USING (true);

-- Posts e Comentários só podem ser inseridos pelo próprio usuário logado
CREATE POLICY "Users can insert their own posts." 
ON posts FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert their own comments." 
ON comments FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Mensagens só podem ser lidas se o usuário for participante do chat (Exige uma function ou join simples no check)
CREATE POLICY "Users can view messages in their chats" 
ON messages FOR SELECT USING (
  auth.uid() IN (SELECT user_id FROM chat_participants WHERE chat_id = messages.chat_id)
);
```

### 3. Configuração do Realtime no Flutter (Threads e Chats)

Substitua o comportamento mockado do `ChatRepository` ou `PostRepository` para ouvir o banco em tempo real usando o `supabase_flutter`.

**Escutando Respostas em Tempo Real numa Thread (`PostDetailScreen`):**
```dart
// Em PostRepositoryImpl:
final supabase = Supabase.instance.client;

Stream<List<Map<String, dynamic>>> streamComments(String postId) {
  return supabase
      .from('comments')
      .stream(primaryKey: ['id'])
      .eq('post_id', postId)
      .order('created_at', ascending: true) // Chronological top-to-bottom
      .map((maps) => maps.map((comment) => {
            'id': comment['id'],
            'content': comment['content'],
            'authorName': comment['profiles']['display_name'], // Exige join manual ou View
            'timeAgo': comment['created_at'],
          }).toList());
}
```

Ao consumir isso num `StreamBuilder` dentro de `PostDetailScreen`, se outro usuário responder ao post, a lista de comentários fará um "pop" automático na tela do usuário que está lendo a thread, replicando a sensação instantânea do X/Twitter!

No `ChatWindowComponent` (camada UI), basta consumir essa stream usando um `StreamBuilder` e a interface reagirá sem fazer *long-polling*.

### 4. Supabase Storage para Avatares e Imagens

Crie um bucket chamado `public_media` no Supabase Storage e ajuste as políticas para "Public".
Para fazer o upload do Flutter em `UserRepositoryImpl.uploadAvatar`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future<String> uploadAvatar(XFile image) async {
  final supabase = Supabase.instance.client;
  final file = File(image.path);
  final fileExt = image.path.split('.').last;
  final fileName = '${DateTime.now().toIso8601String()}.$fileExt';
  final filePath = 'avatars/$fileName';

  await supabase.storage.from('public_media').upload(filePath, file);

  final String publicUrl = supabase.storage.from('public_media').getPublicUrl(filePath);
  
  // Opcional: já atualize o profile com a URL:
  await updateProfile({'avatar_url': publicUrl});
  
  return publicUrl;
}
```

---
**Próximos Passos:** 
A aplicação Flutter agora possui a camada `lib/data/repositories` implementada com o padrão Contract/Impl. O time de desenvolvimento deve escolher uma dessas opções acima e substituir as chamadas mockadas dentro do `Impl` pelas funções REST ou chamadas do SDK do Supabase.
