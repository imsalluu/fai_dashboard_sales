import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard.dart';
import '../../features/sales/presentation/pages/sales_dashboard.dart';
import '../../models/user.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) {
        return authState.user!.role == UserRole.admin ? '/admin' : '/sales';
      }
      
      if (isLoggedIn && state.matchedLocation == '/') {
        return authState.user!.role == UserRole.admin ? '/admin' : '/sales';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
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
