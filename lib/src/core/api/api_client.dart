import 'dart:async';

import 'package:dio/dio.dart';
import 'package:ecclesia_frontend/src/core/api/auth_state.dart';
import 'package:ecclesia_frontend/src/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);

  final dio = Dio(BaseOptions(
    baseUrl: config.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add request/response logging in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (obj) => debugPrint('[HTTP] $obj'),
    ));
  }

  dio.interceptors.add(AuthInterceptor(ref, dio));
  return dio;
});

/// Interceptor responsible for:
/// 1. Automatically attaching `Authorization: Bearer <token>` to every request.
/// 2. Automatically attaching `X-Tenant-Id` to every request.
/// 3. Intercepting 401 responses and attempting a silent token refresh.
/// 4. Queuing concurrent requests during a refresh to avoid refresh storms.
/// 5. Performing logout (clear storage + update [authStateProvider]) on refresh failure.
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  // Lock to prevent multiple simultaneous refresh calls.
  bool _isRefreshing = false;

  // Queue of completers waiting for the refresh to finish.
  final List<Completer<String?>> _refreshQueue = [];

  AuthInterceptor(this._ref, this._dio);

  // ─── onRequest ────────────────────────────────────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    final tenantId = await _storage.read(key: 'tenant_id');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (tenantId != null) {
      options.headers['X-Tenant-Id'] = tenantId;
    }

    handler.next(options);
  }

  // ─── onError ──────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // If the 401 came from the refresh endpoint itself, the session is truly
    // expired — log out immediately to avoid an infinite loop.
    if (_isRefreshRequest(err.requestOptions)) {
      await _performLogout();
      return handler.next(err);
    }

    // If a refresh is already in progress, queue this request and wait.
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _refreshQueue.add(completer);

      final newToken = await completer.future;
      if (newToken == null) {
        return handler.next(err);
      }

      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      try {
        final response = await _retry(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    // This request is the first to hit 401 — attempt the refresh.
    _isRefreshing = true;

    try {
      final newToken = await _refreshTokens();

      if (newToken == null) {
        // Refresh failed — resolve all queued requests with null (they will fail).
        _resolveQueue(null);
        await _performLogout();
        return handler.next(err);
      }

      // Refresh succeeded — resolve all queued requests with the new token.
      _resolveQueue(newToken);

      // Retry the original request.
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final response = await _retry(err.requestOptions);
      return handler.resolve(response);
    } catch (e) {
      _resolveQueue(null);
      await _performLogout();
      return handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Returns true if the request that triggered the 401 was the refresh call.
  bool _isRefreshRequest(RequestOptions options) {
    return options.path.contains('/auth/refresh');
  }

  /// Attempts to exchange the stored refresh token for new tokens.
  /// Returns the new access token on success, or null on failure.
  Future<String?> _refreshTokens() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

    try {
      // Use a separate Dio instance to bypass this interceptor and avoid loops.
      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['accessToken'] as String?;
        final newRefreshToken = response.data['refreshToken'] as String?;

        if (newAccessToken == null) return null;

        await _storage.write(key: 'access_token', value: newAccessToken);
        if (newRefreshToken != null) {
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
        }

        return newAccessToken;
      }
    } catch (_) {
      // Any error during refresh means we cannot recover.
    }

    return null;
  }

  /// Retries the original request using the shared [_dio] instance
  /// (which already has the correct base URL and interceptors).
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) {
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }

  /// Resolves all queued completers with [token].
  void _resolveQueue(String? token) {
    for (final completer in _refreshQueue) {
      completer.complete(token);
    }
    _refreshQueue.clear();
  }

  /// Clears all stored credentials and signals the app to redirect to login.
  Future<void> _performLogout() async {
    await _storage.deleteAll();
    // Update the reactive auth state so GoRouter redirects to /login.
    _ref.read(authStateProvider.notifier).state = AuthStatus.unauthenticated;
  }
}
