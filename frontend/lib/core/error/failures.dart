import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Provides type-safe error handling across all layers
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const Failure({required this.message, this.statusCode, this.errors});

  @override
  List<Object?> get props => [message, statusCode, errors];
}

/// Server-side failures (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.statusCode,
    super.errors,
  });
}

/// Client-side failures (4xx errors)
class ClientFailure extends Failure {
  const ClientFailure({
    super.message = 'Client error occurred',
    super.statusCode,
    super.errors,
  });
}

/// Network connectivity failures
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Cache/storage failures
class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({super.message = 'Validation error', super.errors});
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.statusCode,
  });
}

/// Authorization failures (insufficient permissions)
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    super.message = 'Permission denied',
    super.statusCode = 403,
  });
}

/// Not found failures (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.statusCode = 404,
  });
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'Request timeout'});
}

/// Unknown/unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred',
    super.errors,
  });
}
