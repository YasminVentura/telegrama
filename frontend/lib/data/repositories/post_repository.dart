import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/feed/models/post_model.dart';
import 'package:frontend/shared/components/user_avatar.dart';

abstract class PostRepository {
  Future<List<PostModel>> getFeedPosts({int page = 1, int limit = 10});
  Future<PostModel?> getPostById(String postId);
  Future<List<PostModel>> getUserPosts(String nodeId);
  Future<List<PostModel>> getLikedPosts(String nodeId);
  Future<List<PostModel>> getSavedPosts(String nodeId);
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag);
  Future<PostModel?> likePost(String postId);
  Future<PostModel?> savePost(String postId);
  Future<void> deletePost(String postId);
  Future<void> repost(String postId);
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId);
  Future<Map<String, dynamic>> addCommentToPost(
    String postId,
    String content, {
    String? parentId,
  });
  Future<Map<String, dynamic>?> likeComment(String postId, String commentId);
  Future<List<PostModel>> searchPosts(String query);
}

class PostRepositoryImpl implements PostRepository {
  final ApiClient _apiClient;

  PostRepositoryImpl({ApiClient? apiClient})
      : _apiClient = apiClient ??
            ApiClient(
              baseUrl: kIsWeb
                  ? 'http://localhost:8080'
                  : (defaultTargetPlatform == TargetPlatform.android
                      ? 'http://10.0.2.2:8080'
                      : 'http://localhost:8080'),
            );

  @override
  Future<List<PostModel>> getFeedPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get('/posts?page=$page&limit=$limit');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar feed posts: $e');
    }
    return [];
  }

  @override
  Future<PostModel?> getPostById(String postId) async {
    try {
      final response = await _apiClient.get('/posts/$postId');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is Map) {
          return PostModel.fromJson(Map<String, dynamic>.from(rawData));
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar post $postId: $e');
    }
    return null;
  }

  @override
  Future<List<PostModel>> getUserPosts(String nodeId) async {
    try {
      final response = await _apiClient.get('/posts/usuario/$nodeId');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar posts do usuario $nodeId: $e');
    }
    return [];
  }

  @override
  Future<List<PostModel>> getLikedPosts(String nodeId) async {
    try {
      final response = await _apiClient.get('/posts/usuario/$nodeId/curtidas');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar posts curtidos de $nodeId: $e');
    }
    return [];
  }

  @override
  Future<List<PostModel>> getSavedPosts(String nodeId) async {
    try {
      final response = await _apiClient.get('/posts/usuario/$nodeId/salvos');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar posts salvos de $nodeId: $e');
    }
    return [];
  }

  @override
  Future<void> createPost(
    String content,
    String? imageUrl,
    String? frequencyTag,
  ) async {
    await _apiClient.post('/posts', body: {'content': content});
  }

  @override
  Future<PostModel?> likePost(String postId) async {
    final response = await _apiClient.post('/posts/$postId/curtir');
    if (response != null) {
      final rawData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      if (rawData is Map) {
        return PostModel.fromJson(Map<String, dynamic>.from(rawData));
      }
    }
    return null;
  }

  @override
  Future<PostModel?> savePost(String postId) async {
    final response = await _apiClient.post('/posts/$postId/salvar');
    if (response != null) {
      final rawData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      if (rawData is Map) {
        return PostModel.fromJson(Map<String, dynamic>.from(rawData));
      }
    }
    return null;
  }

  @override
  Future<void> deletePost(String postId) async {
    await _apiClient.delete('/posts/$postId');
  }

  @override
  Future<void> repost(String postId) async {}

  @override
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId) async {
    try {
      final response = await _apiClient.get('/posts/$postId/comentarios');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => _normalizarComentario(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar comentários do post $postId: $e');
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> addCommentToPost(
    String postId,
    String content, {
    String? parentId,
  }) async {
    final body = <String, dynamic>{
      'content': content,
      if (parentId != null && parentId.isNotEmpty) 'parentId': parentId,
    };
    final response = await _apiClient.post('/posts/$postId/comentarios', body: body);
    if (response != null) {
      final rawData = response is Map && response.containsKey('data')
          ? response['data']
          : response;
      if (rawData is Map) {
        return _normalizarComentario(Map<String, dynamic>.from(rawData));
      }
    }
    return {
      'id': 'comment_${DateTime.now().millisecondsSinceEpoch}',
      'parentId': parentId,
      'authorName': 'Você',
      'authorHandle': '@node',
      'content': content,
      'timeAgo': 'Agora',
      'likesCount': 0,
      'curtidoPeloUsuario': false,
      'replies': <Map<String, dynamic>>[],
    };
  }

  @override
  Future<Map<String, dynamic>?> likeComment(String postId, String commentId) async {
    try {
      final response = await _apiClient.post('/posts/$postId/comentarios/$commentId/curtir');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is Map) {
          return _normalizarComentario(Map<String, dynamic>.from(rawData));
        }
      }
    } catch (e) {
      debugPrint('Erro ao curtir comentário $commentId: $e');
    }
    return null;
  }

  Map<String, dynamic> _normalizarComentario(Map<String, dynamic> json) {
    DateTime data = DateTime.now();
    if (json['createdAt'] != null) {
      data = DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now();
    } else if (json['created_at'] != null) {
      data = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    final rawHandle = (json['authorId'] ?? json['authorHandle'] ?? '@node').toString();
    final handle = rawHandle.startsWith('@') ? rawHandle : '@$rawHandle';
    final rawAvatar = json['authorAvatarUrl']?.toString();

    final List<Map<String, dynamic>> repliesList = [];
    if (json['replies'] is List) {
      for (final r in (json['replies'] as List)) {
        if (r is Map) {
          repliesList.add(_normalizarComentario(Map<String, dynamic>.from(r)));
        }
      }
    }

    return {
      'id': json['id']?.toString() ?? '',
      'parentId': json['parentId']?.toString(),
      'authorName': json['authorName'] ?? 'Node Anônimo',
      'authorHandle': handle,
      'authorAvatarUrl': UserAvatar.resolvePresetAsset(rawAvatar) ?? rawAvatar,
      'content': json['content'] ?? '',
      'timeAgo': json['timeAgo'] ?? _calcularTempoAtras(data),
      'likesCount': (json['likes'] ?? json['likesCount'] ?? 0) as int,
      'curtidoPeloUsuario': json['curtidoPeloUsuario'] == true,
      'replies': repliesList,
    };
  }

  static String _calcularTempoAtras(DateTime data) {
    final diferenca = DateTime.now().difference(data);
    if (diferenca.inDays > 0) return '${diferenca.inDays}d atrás';
    if (diferenca.inHours > 0) return '${diferenca.inHours}h atrás';
    if (diferenca.inMinutes > 0) return '${diferenca.inMinutes}m atrás';
    return 'Agora';
  }

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      final response = await _apiClient.get('/posts/busca?q=${Uri.encodeComponent(query)}');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data')
            ? response['data']
            : response;
        if (rawData is List) {
          return rawData
              .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar postagens: $e');
    }
    return [];
  }
}
