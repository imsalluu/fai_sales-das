import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? decode(String? token) {
    if (token == null || token.isEmpty) return null;
    
    final parts = token.split('.');
    if (parts.length != 3) return null;
    
    try {
      final payload = parts[1];
      var normalized = base64.normalize(payload);
      final resp = utf8.decode(base64.decode(normalized));
      return jsonDecode(resp);
    } catch (e) {
      return null;
    }
  }

  static String? getRole(String? token) {
    final payload = decode(token);
    if (payload == null) return null;
    
    // Check common role fields in JWT
    return payload['role'] ?? payload['user_role'] ?? payload['permissions']?[0];
  }
}
