import 'package:frontend/core/network/api_client.dart';

abstract class PostRepository {
  Future<List<Map<String, dynamic>>> getFeedPosts({int page = 1, int limit = 10});
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag);
  Future<void> likePost(String postId);
  Future<void> repost(String postId);
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId);
  Future<Map<String, dynamic>> addCommentToPost(String postId, String content);
}

class PostRepositoryImpl implements PostRepository {
  final ApiClient _apiClient;

  PostRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(baseUrl: 'http://127.0.0.1:8080');

  @override
  Future<List<Map<String, dynamic>>> getFeedPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get('/posts?page=$page&limit=$limit');
      if (response != null && response['data'] != null) {
        final List data = response['data'];
        return data.map((item) {
          final map = Map<String, dynamic>.from(item);
          return {
            'id': map['id']?.toString() ?? '',
            'authorName': map['authorName'] ?? map['author_name'] ?? 'Node Anônimo',
            'authorHandle': map['authorHandle'] ?? map['author_id'] ?? '@node',
            'timeAgo': map['created_at'] != null ? _formatarTempo(map['created_at']) : 'Agora',
            'frequencyTag': map['frequencyTag'] ?? '',
            'content': map['content'] ?? map['conteudo'] ?? '',
            'imageUrl': map['author_avatar_url'],
            'likesCount': (map['likesCount'] ?? map['likes'] ?? 0) as int,
            'commentsCount': (map['commentsCount'] ?? map['comments'] ?? 0) as int,
            'repostsCount': 0,
            'curtidoPeloUsuario': map['curtidoPeloUsuario'] ?? false,
          };
        }).toList();
      }
    } catch (e) {
      print('Erro ao carregar posts: $e');
    }
    return [];
  }

  @override
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag) async {
    await _apiClient.post('/posts', body: {'content': content});
  }

  @override
  Future<void> likePost(String postId) async {
    await _apiClient.post('/posts/$postId/curtir');
  }

  @override
  Future<void> repost(String postId) async {
    // Funcionalidade futura
  }

  @override
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId) async {
    // Funcionalidade futura de comentários
    return [];
  }

  @override
  Future<Map<String, dynamic>> addCommentToPost(String postId, String content) async {
    return {
      'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
      'authorName': 'Você',
      'authorHandle': '@node',
      'content': content,
      'timeAgo': 'Agora',
      'likesCount': 0,
    };
  }

  String _formatarTempo(String dataIso) {
    try {
      final data = DateTime.parse(dataIso);
      final diferenca = DateTime.now().difference(data);
      if (diferenca.inMinutes < 1) return 'Agora';
      if (diferenca.inMinutes < 60) return '${diferenca.inMinutes}m';
      if (diferenca.inHours < 24) return '${diferenca.inHours}h';
      return '${diferenca.inDays}d';
    } catch (_) {
      return 'Agora';
    }
  }
}
