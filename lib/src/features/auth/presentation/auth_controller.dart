import 'package:ecclesia_frontend/src/core/api/auth_state.dart';
import 'package:ecclesia_frontend/src/features/auth/data/auth_repository.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/finance_controller.dart';
import 'package:ecclesia_frontend/src/features/finance/presentation/scope_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.read(authRepositoryProvider), ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthController(this._repository, this._ref) : super(const AsyncData(null));

  /// Authenticates the user, stores tokens, and updates [authStateProvider].
  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      // 1. Clear ANY existing data from previous sessions before starting a new login
      await _storage.deleteAll();
      
      final response = await _repository.login(email, password);

      // Persist tokens securely
      await _storage.write(key: 'access_token', value: response.accessToken);
      await _storage.write(key: 'refresh_token', value: response.refreshToken);

      // Extract and persist tenant ID and mode from the JWT payload
      final decodedToken = JwtDecoder.decode(response.accessToken);
      final tenantId = decodedToken['tenantId']?.toString();
      final mode = decodedToken['organizationMode']?.toString();

      if (tenantId != null) {
        await _storage.write(key: 'tenant_id', value: tenantId);
      }
      if (mode != null) {
        await _storage.write(key: 'organization_mode', value: mode);
        _ref.read(organizationModeProvider.notifier).state = mode;
      }

      // Signal the app that the user is now authenticated.
      // GoRouter will react and redirect away from /login.
      _ref.read(authStateProvider.notifier).state = AuthStatus.authenticated;

      // 4. Invalidate all finance-related providers to ensure fresh data for the new session
      _ref.invalidate(scopeControllerProvider);
      _ref.invalidate(userRoleProvider);
      _ref.invalidate(transactionsControllerProvider);
      _ref.invalidate(categoriesControllerProvider);
      _ref.invalidate(reportSummaryControllerProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Clears all stored credentials and signals the app to redirect to /login.
  Future<void> logout() async {
    await _storage.deleteAll();
    // Signal the app that the user is now unauthenticated.
    // GoRouter will react and redirect to /login.
    _ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
    state = const AsyncData(null);
  }
}
