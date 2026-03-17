import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/sales/presentation/pages/sales_dashboard.dart';
import '../../models/user.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // final authState = ref.watch(authProvider); // Removed

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isLoggedIn = auth.user != null;
      
      final unauthRoutes = ['/login', '/forgot-password', '/verify-otp', '/reset-password'];
      final isGoingToUnauthRoute = unauthRoutes.contains(state.matchedLocation);

      if (!isLoggedIn && !isGoingToUnauthRoute) return '/login';
      if (isLoggedIn && isGoingToUnauthRoute) {
        return auth.user!.role == UserRole.sales_admin ? '/admin' : '/sales';
      }
      
      if (isLoggedIn && state.matchedLocation == '/') {
        return auth.user!.role == UserRole.sales_admin ? '/admin' : '/sales';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/verify-otp',
        builder: (context, state) => const VerifyOtpPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/sales',
        builder: (context, state) => const SalesDashboard(),
      ),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}
