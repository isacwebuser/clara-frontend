import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the authentication status of the user.
enum AuthStatus {
  /// The user is authenticated and has valid tokens.
  authenticated,

  /// The user is not authenticated (logged out or session expired).
  unauthenticated,
}

/// Global provider for the current authentication state.
final authStateProvider = StateProvider<AuthStatus>((ref) {
  return AuthStatus.unauthenticated;
});

/// Global provider for the current organization mode.
final organizationModeProvider = StateProvider<String?>((ref) {
  return null;
});
