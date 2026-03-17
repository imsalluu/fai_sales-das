import '../../core/services/network/network_client.dart';

class ApiService {
  final NetworkClient _client;
  final String _baseUrl = 'https://sales-backend.fireai.agency/api/v1';

  ApiService(this._client);

  Future<NetworkResponse> login(String email, String password) async {
    return _client.postRequest(
      '$_baseUrl/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );
  }


  Future<NetworkResponse> getMyStats({int? year, int? month}) async {
    String url = '$_baseUrl/dashboard/my-stats';
    if (year != null && month != null) {
      url += '?year=$year&month=$month';
    } else if (year != null) {
      url += '?year=$year';
    } else if (month != null) {
      url += '?month=$month';
    }
    return _client.getRequest(url);
  }

  Future<NetworkResponse> getExecutiveStats({int? year, int? month}) async {
    String url = '$_baseUrl/dashboard/executive-stats';
    if (year != null && month != null) {
      url += '?year=$year&month=$month';
    } else if (year != null) {
      url += '?year=$year';
    } else if (month != null) {
      url += '?month=$month';
    }
    return _client.getRequest(url);
  }

  Future<NetworkResponse> getProjects() async {
    return _client.getRequest('$_baseUrl/projects');
  }

  Future<NetworkResponse> getProjectById(String id) async {
    return _client.getRequest('$_baseUrl/projects/$id');
  }

  Future<NetworkResponse> getMembers() async {
    // Note: /users/members returned 404, using /users as fallback or per backend structure
    return _client.getRequest('$_baseUrl/users');
  }

  Future<NetworkResponse> getUsers() async {
    return _client.getRequest('$_baseUrl/users');
  }

  Future<NetworkResponse> createUser(Map<String, dynamic> data) async {
    return _client.postRequest(
      '$_baseUrl/users',
      body: data,
    );
  }

  Future<NetworkResponse> updateUser(String id, Map<String, dynamic> data) async {
    return _client.putRequest(
      '$_baseUrl/users/$id',
      body: data,
    );
  }

  Future<NetworkResponse> deleteUser(String id) async {
    return _client.deleteRequest('$_baseUrl/users/$id');
  }

  Future<NetworkResponse> createProject(Map<String, dynamic> data) async {
    return _client.postRequest(
      '$_baseUrl/projects',
      body: data,
    );
  }

  Future<NetworkResponse> createAdminProject(Map<String, dynamic> data) async {
    return _client.postRequest(
      '$_baseUrl/projects/admin',
      body: data,
    );
  }

  Future<NetworkResponse> updateProject(String id, Map<String, dynamic> data) async {
    return _client.putRequest(
      '$_baseUrl/projects/$id',
      body: data,
    );
  }

  Future<NetworkResponse> deleteProject(String id) async {
    return _client.deleteRequest('$_baseUrl/projects/$id');
  }

  Future<NetworkResponse> getPerformance() async {
    return _client.getRequest('$_baseUrl/performance');
  }

  Future<NetworkResponse> getNotifications() async {
    return _client.getRequest('$_baseUrl/notifications');
  }

  // --- Password Recovery Methods ---

  Future<NetworkResponse> forgotPassword(String email) async {
    return _client.postRequest(
      '$_baseUrl/auth/forgot-password',
      body: {'email': email},
    );
  }

  Future<NetworkResponse> verifyOtp(String email, String otp) async {
    return _client.postRequest(
      '$_baseUrl/auth/verify-otp',
      body: {'email': email, 'otp': otp},
    );
  }

  Future<NetworkResponse> resetPassword(String email, String otp, String newPassword) async {
    return _client.postRequest(
      '$_baseUrl/auth/reset-password',
      body: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      },
    );
  }
}
