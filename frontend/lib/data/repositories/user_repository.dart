import 'package:image_picker/image_picker.dart';

abstract class UserRepository {
  Future<Map<String, dynamic>> getUserProfile(String userId);
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<String> uploadAvatar(XFile image);
  Future<void> followUser(String userId);
  Future<void> unfollowUser(String userId);
}

class UserRepositoryImpl implements UserRepository {
  @override
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    // Stub: Simula latência de rede
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'id': userId,
      'name': 'Saskia Vance',
      'handle': '@sas_vance',
      'bio': 'Exploring high-contrast textures, vintage print design, and modern geometry. Based in Berlin.',
      'location': 'Berlin, Germany',
      'followingCount': 1200,
      'followersCount': 45900,
      'artifactsCount': 184,
    };
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    // Stub: Simula update via API
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Future<String> uploadAvatar(XFile image) async {
    // Stub: Simula upload de arquivo para bucket e retorna a URL
    await Future.delayed(const Duration(milliseconds: 1500));
    return 'https://exemplo.com/avatar_mock.jpg'; 
  }

  @override
  Future<void> followUser(String userId) async {
    // Stub: Simula registro de follow
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> unfollowUser(String userId) async {
    // Stub: Simula deleção de follow
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
