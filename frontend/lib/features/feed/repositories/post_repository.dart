import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/feed/models/post_model.dart';

class PostRepository {
  final ApiClient _apiClient;

  PostRepository([ApiClient? apiClient])
      : _apiClient = apiClient ??
            ApiClient(
              baseUrl: kIsWeb
                  ? 'http://localhost:8080'
                  : (defaultTargetPlatform == TargetPlatform.android
                      ? 'http://10.0.2.2:8080'
                      : 'http://localhost:8080'),
            );

  Future<List<PostModel>> fetchPosts({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get('/posts?page=$page&limit=$limit');
    if (response != null && response['data'] != null) {
      final List data = response['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<PostModel>> fetchUserPosts(String nodeId) async {
    final response = await _apiClient.get('/posts/usuario/$nodeId');
    if (response != null && response['data'] != null) {
      final List data = response['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<PostModel> createPost(String content) async {
    final response = await _apiClient.post('/posts', body: {'content': content});
    return PostModel.fromJson(response['data']);
  }

  Future<PostModel?> likePost(String id) async {
    final response = await _apiClient.post('/posts/$id/curtir');
    if (response != null && response['data'] != null) {
      return PostModel.fromJson(response['data']);
    }
    return null;
  }
}
