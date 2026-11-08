import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/feed/models/post_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> getFeedPosts({int page = 1, int limit = 10});
  Future<List<PostModel>> getUserPosts(String nodeId);
  Future<List<PostModel>> getLikedPosts(String nodeId);
  Future<List<PostModel>> getSavedPosts(String nodeId);
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag);
  Future<PostModel?> likePost(String postId);
  Future<PostModel?> savePost(String postId);
  Future<void> deletePost(String postId);
  Future<void> repost(String postId);
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId);
  Future<Map<String, dynamic>> addCommentToPost(String postId, String content);
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
          return rawData.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar feed posts: $e');
    }
    return [];
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
          return rawData.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item))).toList();
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
          return rawData.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item))).toList();
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
          return rawData.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar posts salvos de $nodeId: $e');
    }
    return [];
  }

  @override
  Future<void> createPost(String content, String? imageUrl, String? frequencyTag) async {
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
  Future<void> repost(String postId) async {
    // Funcionalidade futura
  }

  @override
  Future<List<Map<String, dynamic>>> getCommentsForPost(String postId) async {
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

  @override
  Future<List<PostModel>> searchPosts(String query) async {
    try {
      final response = await _apiClient.get('/posts/busca?q=${Uri.encodeComponent(query)}');
      if (response != null) {
        final rawData = response is Map && response.containsKey('data') 
            ? response['data'] 
            : response;
        if (rawData is List) {
          return rawData.map((item) => PostModel.fromJson(Map<String, dynamic>.from(item))).toList();
        }
      }
    } catch (e) {
      debugPrint('Erro ao buscar postagens: $e');
    }
    return [];
  }
}
