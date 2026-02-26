import 'package:ecclesia_frontend/src/core/api/auth_state.dart';
import 'package:ecclesia_frontend/src/features/auth/presentation/login_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/dashboard_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/categories_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/transactions_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/monthly_report_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/branch_management_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/organizational_report_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/periods_screen.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/audit_trail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A [RouteObserver] key used by GoRouter to listen to [authStateProvider].
///
/// By watching [authStateProvider] inside the provider, GoRouter will
/// automatically call [redirect] whenever the auth state changes — no manual
/// navigation calls needed anywhere in the app.
final goRouterProvider = Provider<GoRouter>((ref) {
  // Create a notifier that GoRouter can listen to for refreshes.
  final authNotifier = _AuthStateNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: authNotifier,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/monthly-report',
        builder: (context, state) => const MonthlyReportScreen(),
      ),
      GoRoute(
        path: '/branches',
        builder: (context, state) => const BranchManagementScreen(),
      ),
      GoRoute(
        path: '/organizational-report',
        builder: (context, state) => const OrganizationalReportScreen(),
      ),
      GoRoute(
        path: '/periods',
        builder: (context, state) => const PeriodsScreen(),
      ),
      GoRoute(
        path: '/audit-trail',
        builder: (context, state) => const AuditTrailScreen(),
      ),
    ],
    redirect: (context, state) {
      final authStatus = ref.read(authStateProvider);
      final isLoggedIn = authStatus == AuthStatus.authenticated;
      final isOnLogin = state.uri.path == '/login';

      if (!isLoggedIn && !isOnLogin) {
        // Not authenticated → force to login
        return '/login';
      }
      if (isLoggedIn && isOnLogin) {
        // Already authenticated → skip login screen
        return '/dashboard';
      }
      // No redirect needed
      return null;
    },
  );
});

/// A [ChangeNotifier] that bridges [authStateProvider] to GoRouter's
/// [refreshListenable]. Whenever [authStateProvider] changes, GoRouter
/// re-evaluates its [redirect] function.
class _AuthStateNotifier extends ChangeNotifier {
  _AuthStateNotifier(Ref ref) {
    ref.listen<AuthStatus>(authStateProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }
}
