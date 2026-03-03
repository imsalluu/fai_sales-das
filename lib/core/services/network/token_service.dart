import 'package:shared_preferences/shared_preferences.dart';

class TokenService {
  static String? accessToken;
  static String? refreshToken;
  static String? userRole;
  static String? userId;
  static String? userName;
  static String? userEmail;

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _roleKey = 'user_role';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';

  static bool get isLoggedIn => accessToken != null;

  /// Load tokens on app start
  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString(_accessKey);
    refreshToken = prefs.getString(_refreshKey);
    userRole = prefs.getString(_roleKey);
    userId = prefs.getString(_userIdKey);
    userName = prefs.getString(_userNameKey);
    userEmail = prefs.getString(_userEmailKey);
  }

  /// Save tokens and role after login
  static Future<void> saveTokens({
    required String access,
    String? refresh,
    String? role,
    String? id,
    String? name,
    String? email,
  }) async {
    accessToken = access;
    if (refresh != null) refreshToken = refresh;
    if (role != null) userRole = role;
    if (id != null) userId = id;
    if (name != null) userName = name;
    if (email != null) userEmail = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    if (refresh != null) {
      await prefs.setString(_refreshKey, refresh);
    }
    if (role != null) {
      await prefs.setString(_roleKey, role);
    }
    if (id != null) {
      await prefs.setString(_userIdKey, id);
    }
    if (name != null) {
      await prefs.setString(_userNameKey, name);
    }
    if (email != null) {
      await prefs.setString(_userEmailKey, email);
    }
  }

  /// Clear on logout
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = null;
    refreshToken = null;
    userRole = null;
    userId = null;
    userName = null;
    userEmail = null;

    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }
}
