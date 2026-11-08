import 'dart:convert';
import 'session_storage_stub.dart'
    if (dart.library.html) 'session_storage_web.dart';

class SessionStorage {
  static const String _keySessionId = 'telegrama_session_id';
  static const String _keyRefreshToken = 'telegrama_refresh_token';
  static const String _keyUserData = 'telegrama_user_data';

  static String? getSessionId() => readStorageKey(_keySessionId);

  static void saveSessionId(String sessionId) {
    if (sessionId.isNotEmpty) {
      writeStorageKey(_keySessionId, sessionId);
    }
  }

  static String? getRefreshToken() => readStorageKey(_keyRefreshToken);

  static void saveRefreshToken(String refreshToken) {
    if (refreshToken.isNotEmpty) {
      writeStorageKey(_keyRefreshToken, refreshToken);
    }
  }

  static Map<String, dynamic>? getUserData() {
    final raw = readStorageKey(_keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  static void saveUserData(Map<String, dynamic> data) {
    try {
      writeStorageKey(_keyUserData, jsonEncode(data));
    } catch (_) {}
  }

  static void clearAll() {
    removeStorageKey(_keySessionId);
    removeStorageKey(_keyRefreshToken);
    removeStorageKey(_keyUserData);
  }
}

