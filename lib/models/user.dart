enum UserRole { sales_admin, sales_member }

class User {
  final String id;
  final String name;
  final String email;
  final String? password;
  final UserRole role;
  final String? profileImage;
  final String? accessToken;
  final String? refreshToken;
  final String status;
  final int totalQueries;
  final int convertedQueries;
  final int quoteSent;
  final double conversionRate;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.role,
    this.profileImage,
    this.accessToken,
    this.refreshToken,
    this.status = 'active',
    this.totalQueries = 0,
    this.convertedQueries = 0,
    this.quoteSent = 0,
    this.conversionRate = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    UserRole parseRole(String? role) {
      if (role == null) return UserRole.sales_member;
      final normalized = role.toLowerCase();
      if (normalized.contains('admin')) {
        return UserRole.sales_admin;
      }
      return UserRole.sales_member;
    }

    return User(
      id: json['id'] ?? json['_id'] ?? json['userId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      role: parseRole(json['role']),
      profileImage: json['image'],
      accessToken: json['accessToken'] ?? json['token'],
      refreshToken: json['refreshToken'],
      status: json['status'] ?? 'active',
      totalQueries: json['total_queries'] ?? 0,
      convertedQueries: json['converted_queries'] ?? 0,
      quoteSent: json['quote_sent'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'image': profileImage,
      'status': status,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? profileImage,
    String? accessToken,
    String? refreshToken,
    String? status,
    int? totalQueries,
    int? convertedQueries,
    int? quoteSent,
    double? conversionRate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      status: status ?? this.status,
      totalQueries: totalQueries ?? this.totalQueries,
      convertedQueries: convertedQueries ?? this.convertedQueries,
      quoteSent: quoteSent ?? this.quoteSent,
      conversionRate: conversionRate ?? this.conversionRate,
    );
  }
}
