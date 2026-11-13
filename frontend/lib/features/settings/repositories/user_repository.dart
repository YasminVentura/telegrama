import 'dart:async';

class UserRepository {

  final Map<String, bool> _followingState = {};
  int _followersCount = 1284;
  int _followingCount = 42;

  Future<bool> getIsFollowing(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _followingState[userId] ?? false;
  }

  Future<void> followUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _followingState[userId] = true;
    _followingCount += 1;
  }

  Future<void> unfollowUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _followingState[userId] = false;
    _followingCount -= 1;
  }

  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
}
