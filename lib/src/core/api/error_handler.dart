import 'package:dio/dio.dart';

/// Sealed class hierarchy for typed application exceptions.
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when there is no network connectivity or the request timed out.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Sem conexão com a internet. Verifique sua rede.']);
}

/// Thrown when the server returns a 401 Unauthorized response and
/// the token refresh also fails (session expired).
class AuthException extends AppException {
  const AuthException([super.message = 'Sessão expirada. Faça login novamente.']);
}

/// Thrown when the server returns a 403 Forbidden response.
class ForbiddenException extends AppException {
  const ForbiddenException([super.message = 'Você não tem permissão para realizar esta ação.']);
}

/// Thrown when the server returns a 404 Not Found response.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Recurso não encontrado.']);
}

/// Thrown when the server returns a 422 Unprocessable Entity (validation error).
class ValidationException extends AppException {
  final Map<String, dynamic>? errors;
  const ValidationException(super.message, {this.errors});
}

/// Thrown when the server returns a 5xx error.
class ServerException extends AppException {
  final int? statusCode;
  const ServerException([super.message = 'Erro interno no servidor. Tente novamente mais tarde.', this.statusCode]);
}

/// Thrown for any other unexpected error.
class UnknownException extends AppException {
  const UnknownException([super.message = 'Ocorreu um erro inesperado.']);
}

/// Utility class that converts [DioException] into typed [AppException]s.
///
/// Usage in a repository or controller:
/// ```dart
/// try {
///   final response = await _dio.get('/endpoint');
/// } on DioException catch (e) {
///   throw ErrorHandler.handle(e);
/// }
/// ```
class ErrorHandler {
  ErrorHandler._();

  /// Converts a [DioException] into a typed [AppException].
  static AppException handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('A requisição excedeu o tempo limite.');

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response);

      case DioExceptionType.cancel:
        return const UnknownException('Requisição cancelada.');

      case DioExceptionType.unknown:
      default:
        // Check if it's a socket/network error wrapped as unknown
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('Connection refused') == true) {
          return const NetworkException();
        }
        return UnknownException(error.message ?? 'Ocorreu um erro inesperado.');
    }
  }

  static AppException _handleStatusCode(Response? response) {
    if (response == null) return const UnknownException();

    final statusCode = response.statusCode;
    final data = response.data;

    // Try to extract a server-provided message
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }

    switch (statusCode) {
      case 400:
        return UnknownException(serverMessage ?? 'Requisição inválida.');
      case 401:
        return AuthException(serverMessage ?? 'Sessão expirada. Faça login novamente.');
      case 403:
        return ForbiddenException(serverMessage ?? 'Você não tem permissão para realizar esta ação.');
      case 404:
        return NotFoundException(serverMessage ?? 'Recurso não encontrado.');
      case 422:
        final errors = data is Map<String, dynamic> ? data['errors'] as Map<String, dynamic>? : null;
        return ValidationException(serverMessage ?? 'Dados inválidos.', errors: errors);
      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(serverMessage ?? 'Erro no servidor. Tente novamente mais tarde.', statusCode);
      default:
        return UnknownException(serverMessage ?? 'Erro desconhecido (HTTP $statusCode).');
    }
  }
}
