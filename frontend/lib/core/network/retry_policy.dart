import 'dart:math';
import 'package:logger/logger.dart';

/// Retry policy for API calls with exponential backoff and jitter
/// Implements industry best practices for resilient network communication
class RetryPolicy {
  final int maxRetries;
  final Duration initialDelay;
  final Duration maxDelay;
  final double exponentialBase;
  final double jitterFactor;
  final Logger _logger;

  RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 10),
    this.exponentialBase = 2.0,
    this.jitterFactor = 0.3,
  }) : _logger = Logger(
         printer: PrettyPrinter(
           methodCount: 0,
           errorMethodCount: 5,
           lineLength: 80,
           colors: true,
           printEmojis: true,
         ),
       );

  /// Execute a function with retry logic
  Future<T> execute<T>(
    Future<T> Function() operation, {
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    dynamic lastError;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastError = e;
        attempt++;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(e)) {
          _logger.w('Non-retryable error encountered: $e');
          rethrow;
        }

        if (attempt >= maxRetries) {
          _logger.e('Max retries ($maxRetries) exceeded for operation');
          rethrow;
        }

        final delay = _calculateDelay(attempt);
        _logger.w(
          'Retry attempt $attempt/$maxRetries after ${delay.inMilliseconds}ms. Error: $e',
        );

        await Future.delayed(delay);
      }
    }

    throw lastError;
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(int attempt) {
    // Exponential backoff: delay = initialDelay * (base ^ attempt)
    final exponentialDelay =
        initialDelay.inMilliseconds *
        pow(exponentialBase, attempt - 1).toDouble();

    // Add jitter to prevent thundering herd problem
    final jitter =
        exponentialDelay * jitterFactor * (Random().nextDouble() - 0.5);
    final delayMs = (exponentialDelay + jitter).clamp(
      initialDelay.inMilliseconds.toDouble(),
      maxDelay.inMilliseconds.toDouble(),
    );

    return Duration(milliseconds: delayMs.round());
  }

  /// Check if error is retryable (network errors, 5xx server errors)
  static bool isRetryableError(dynamic error) {
    // Implement logic based on your error types
    // Example: return error is SocketException || error is TimeoutException
    final errorString = error.toString().toLowerCase();
    return errorString.contains('socket') ||
        errorString.contains('timeout') ||
        errorString.contains('connection') ||
        errorString.contains('network');
  }
}
