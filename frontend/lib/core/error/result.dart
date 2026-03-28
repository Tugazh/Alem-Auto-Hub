import 'failures.dart' as failures;

/// Railway-oriented programming: Result monad for type-safe error handling
/// Eliminates exceptions and makes error handling explicit in the type system
sealed class Result<T> {
  const Result();
}

/// Success case containing the data
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Failure case containing the error
class ResultFailure<T> extends Result<T> {
  final failures.Failure failure;

  const ResultFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'ResultFailure(failure: $failure)';
}

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Execute different code paths based on success or failure
  R when<R>({
    required R Function(T data) success,
    required R Function(failures.Failure failure) failure,
  }) {
    final self = this;
    if (self is Success<T>) {
      return success(self.data);
    } else if (self is ResultFailure<T>) {
      return failure(self.failure);
    }
    throw StateError('Unexpected Result type');
  }

  /// Fold result into a single value
  R fold<R>(
    R Function(failures.Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    return when(success: onSuccess, failure: onFailure);
  }

  /// Map the success value to another type
  Result<R> map<R>(R Function(T data) mapper) {
    return when(
      success: (data) => Success(mapper(data)),
      failure: (failure) => ResultFailure(failure),
    );
  }

  /// Map the failure to another failure
  Result<T> mapError(
    failures.Failure Function(failures.Failure failure) mapper,
  ) {
    return when(
      success: (data) => Success(data),
      failure: (failure) => ResultFailure(mapper(failure)),
    );
  }

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is ResultFailure<T>;

  /// Get data if success, throw if failure
  T get dataOrThrow {
    return when(success: (data) => data, failure: (failure) => throw failure);
  }

  /// Get data if success, return null if failure
  T? get dataOrNull {
    return when(success: (data) => data, failure: (_) => null);
  }

  /// Get failure if failure, return null if success
  failures.Failure? get failureOrNull {
    return when(success: (_) => null, failure: (failure) => failure);
  }
}

/// Helper extensions for easier Result creation
extension ValueToResult<T> on T {
  /// Wrap value in Success
  Result<T> get asSuccess => Success(this);
}

extension FailureToResult on failures.Failure {
  /// Wrap failure in ResultFailure
  Result<T> asFailure<T>() => ResultFailure(this);
}
