import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/features/feed/models/post_model.dart';

class PostRepository {
  final ApiClient _apiClient;

  PostRepository(this._apiClient);

  Future<List<PostModel>> fetchPosts({int page = 1, int limit = 20}) async {
    final response = await _apiClient.get('/posts?page=$page&limit=$limit');
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
}
