import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../services/api/api_service.dart';
import '../../../../core/services/network/network_provider.dart';
import '../../../../core/services/network/token_service.dart';
import '../../../../models/user.dart';
import '../../../../core/utils/jwt_utils.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return ApiService(networkClient);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _api;

  AuthNotifier(this._api) : super(AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    state = state.copyWith(isLoading: true);
    if (TokenService.isLoggedIn) {
      final token = TokenService.accessToken;
      final decodedRole = JwtUtils.getRole(token);
      final roleStr = decodedRole ?? TokenService.userRole;

      state = state.copyWith(
        user: User(
          id: TokenService.userId ?? '',
          name: TokenService.userName ?? 'User',
          email: TokenService.userEmail ?? '',
          role: (roleStr != null && roleStr.toString().toLowerCase().contains('admin')) 
              ? UserRole.sales_admin 
              : UserRole.sales_member,
          accessToken: token,
          refreshToken: TokenService.refreshToken,
        ),
        isLoading: false,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final response = await _api.login(email, password);
    
    if (response.isSuccess) {
      final data = response.responseData;
      final token = data['accessToken'] ?? data['token'];
      final decodedRole = JwtUtils.getRole(token);

      final user = User.fromJson({
        ...data,
        'email': email,
        'name': data['name'] ?? email.split('@').first,
        'role': decodedRole ?? data['role'] ?? (email.contains('admin') ? 'sales_admin' : 'sales_member'),
      });

      await TokenService.saveTokens(
        access: user.accessToken ?? '',
        refresh: user.refreshToken,
        role: user.role == UserRole.sales_admin ? 'sales_admin' : 'sales_member',
        id: user.id,
        name: user.name,
        email: user.email,
      );
      
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: response.errorMassage ?? "Invalid credentials");
      return false;
    }
  }

  Future<void> logout() async {
    await TokenService.clear();
    state = AuthState();
  }
}
