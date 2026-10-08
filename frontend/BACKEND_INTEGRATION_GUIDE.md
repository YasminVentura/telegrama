# Guia de Integração de Backend (Telegrama)

Este guia detalha o processo de integração do front-end do projeto Telegrama com serviços de back-end. Ele cobre tanto uma API RESTful personalizada (Node.js/Express ou Python/Fastify) quanto uma implementação utilizando Supabase.

---

## 1. Estrutura da Camada de Serviços (Já Implementada)

A arquitetura do front-end já foi preparada com uma camada de rede centralizada, utilizando o padrão **Repository**:

*   **`core/network/api_client.dart`**: Wrapper base do pacote `http` para chamadas HTTP seguras, com injeção automática de headers (`Authorization: Bearer <token>`) e conversão de respostas.
*   **`core/network/app_exceptions.dart`**: Tratamento padronizado de erros de rede (400, 401, 404, 500).
*   **Models & Repositories**: Para cada feature, deve existir um `Model` (ex: `PostModel` em `features/feed/models/post_model.dart`) que converte JSON em objetos Dart, e um `Repository` (ex: `PostRepository` em `features/feed/repositories/post_repository.dart`) responsável por comunicar-se com a API.

### Como Injetar Dependências (Gerenciamento de Estado Recomendado)

Para este projeto, devido ao escopo enxuto, sugerimos utilizar **Riverpod** ou **Provider** para injetar o `ApiClient` e os repositórios em toda a árvore de widgets.

Exemplo básico de configuração com Provider (em `main.dart`):

```dart
MultiProvider(
  providers: [
    Provider<ApiClient>(create: (_) => ApiClient(baseUrl: 'https://api.telegrama.zone')),
    ProxyProvider<ApiClient, PostRepository>(
      update: (_, apiClient, __) => PostRepository(apiClient),
    ),
  ],
  child: const MyApp(),
);
```

---

## 2. Integrando com API REST Customizada (Node.js/Python)

Se você for construir seu próprio back-end, os endpoints sugeridos são:

*   **`POST /auth/login`**: Deve retornar um token JWT para ser armazenado via `flutter_secure_storage` e passado ao `ApiClient` através do método `setToken(token)`.
*   **`GET /posts`**: Retorna uma lista paginada de posts. (Implementado em `PostRepository.fetchPosts`).
*   **`POST /posts`**: Recebe o corpo `{ "content": "..." }` e salva no banco de dados.

### Exemplo de Resposta JSON (`GET /posts`):

```json
{
  "data": [
    {
      "id": "12345",
      "author_name": "Saskia Vance",
      "author_id": "sas_vance",
      "author_avatar_url": "https://url.com/avatar.png",
      "content": "Exploring high-contrast textures.",
      "created_at": "2023-10-25T14:30:00.000Z",
      "likes": 42,
      "comments": 5
    }
  ]
}
```

---

## 3. Guia de Implementação com Supabase (Abordagem Recomendada)

Supabase é a escolha ideal para o projeto *Telegrama* pois oferece banco de dados PostgreSQL real-time, autenticação e armazenamento de arquivos prontos para uso.

### 3.1. Configuração do Cliente

1. Adicione a dependência no `pubspec.yaml`:
   ```bash
   flutter pub add supabase_flutter
   ```

2. Inicialize o Supabase no `main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://<sua-ref>.supabase.co',
    anonKey: '<sua-chave-anon>',
  );
  runApp(const MyApp());
}

// Acesso global ao client
final supabase = Supabase.instance.client;
```

### 3.2. Estrutura do Banco de Dados (PostgreSQL)

Você precisará criar as seguintes tabelas no painel do Supabase:

*   **`profiles`**: `id` (uuid, reference to auth.users), `display_name`, `node_id`, `avatar_url`, `bio`.
*   **`posts`**: `id` (uuid), `author_id` (uuid, reference profiles.id), `content`, `created_at`.
*   **`messages`**: `id` (uuid), `chat_id` (uuid), `sender_id` (uuid), `text`, `created_at`.

### 3.3. Implementando Realtime para Chats

Para atualizar a `ChatWindowComponent` instantaneamente sem polling, use a funcionalidade de streams do Supabase.

No seu `ChatRepository`:

```dart
Stream<List<MessageModel>> getChatMessages(String chatId) {
  return supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('chat_id', chatId)
      .order('created_at', ascending: true)
      .map((maps) => maps.map((map) => MessageModel.fromJson(map)).toList());
}
```

Na UI (`ChatWindowComponent`), envolva sua lista de mensagens em um `StreamBuilder`.

### 3.4. Supabase Storage para Upload de Avatares

A troca de avatar (`UserAvatar` e `ProfileSettingsContent`) já utiliza o `image_picker` localmente. Para enviar essa imagem para a nuvem:

1. Crie um bucket público no Supabase chamado `avatars`.
2. Implemente o upload no repositório de usuário:

```dart
Future<String?> uploadAvatar(String userId, String imagePath) async {
  try {
    final file = File(imagePath);
    final fileExt = imagePath.split('.').last;
    final fileName = '$userId-${DateTime.now().toIso8601String()}.$fileExt';

    // Faz o upload do arquivo
    await supabase.storage.from('avatars').upload(fileName, file);
    
    // Obtém a URL pública para salvar no profile
    final imageUrlResponse = supabase.storage.from('avatars').getPublicUrl(fileName);
    
    // Salva a nova URL na tabela de profiles
    await supabase.from('profiles').update({'avatar_url': imageUrlResponse}).eq('id', userId);
    
    return imageUrlResponse;
  } catch (e) {
    print('Erro no upload: $e');
    return null;
  }
}
```

---

## 4. Boas Práticas Neubrutalistas para Estados da API

Ao implementar as chamadas de API na interface gráfica, siga o design system neubrutalista:

*   **Skeletons Customizados:** Em vez de *Spinners* redondos e suaves (`CircularProgressIndicator`), utilize contêineres retangulares na cor cinza claro (`Colors.grey[300]`) com bordas pretas grossas (`Border.all(color: Colors.black, width: 2)`) e sombras offset que se movem de forma abrupta para simular carregamento.
*   **Tratamento de Erros:** Quando uma requisição falhar (`AppException`), não use *SnackBars* minimalistas. Exiba um alerta flutuante de cor viva (Amarelo ou Vermelho saturado), com fontes em negrito (`FontWeight.w900`) e bordas pronunciadas.
*   **Pull to Refresh:** Substitua o `RefreshIndicator` padrão por um widget customizado com iconografia geométrica (ex: um quadrado que gira ou uma fita k7 rebobinando).
