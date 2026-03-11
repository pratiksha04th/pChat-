import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUserId = 'user_id';
  static const _keyEmail = 'email';
  static const _keyUsername = 'username';
  static const String permissionKey = "ai_permission_given";

  /// Save login session
  static Future<void> saveUserSession({
    required String userId,
    required String email,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyUsername, username);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Get stored user data
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_keyUserId) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'username': prefs.getString(_keyUsername) ?? '',
    };
  }

  /// Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }


  /// permission for ai assistant

  static Future<void> setPermissionGiven() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(permissionKey, true);
  }

  static Future<bool> isPermissionGiven() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(permissionKey) ?? false;
  }
}
