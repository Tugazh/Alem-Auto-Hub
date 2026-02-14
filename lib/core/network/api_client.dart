import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

/// API Client для взаимодействия с backend
///
/// Использует Dio для HTTP requests с interceptors для:
/// - Автоматического добавления JWT токена
/// - Логирования запросов/ответов
/// - Обработки ошибок
class ApiClient {
  late final Dio _dio;

  // Backend URL: автоматически определяется для симуляторов
  static String get _baseUrl {
    if (kDebugMode) {
      // Android эмулятор использует 10.0.2.2 для доступа к host machine
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080/api/v1';
      }
      // iOS симулятор и macOS используют localhost
      return 'http://localhost:8080/api/v1';
    }
    // Production URL (замените на ваш домен)
    return 'https://api.auto-one.com/api/v1';
  }

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Логируем базовый URL для отладки
    if (kDebugMode) {
      print('🌐 API Base URL: $_baseUrl');
    }

    _initializeInterceptors();
  }

  void _initializeInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Добавить JWT token из storage
          // final token = await SecureStorage.getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }

          if (kDebugMode) {
            debugPrint('🌐 Request: ${options.method} ${options.path}');
            debugPrint('📦 Data: ${options.data}');
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint(
              '✅ Response: ${response.statusCode} ${response.requestOptions.path}',
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint(
              '❌ Error: ${error.response?.statusCode} ${error.requestOptions.path}',
            );
            debugPrint('📛 Message: ${error.message}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Connection timeout');
      case DioExceptionType.badResponse:
        return ServerException(
          error.response?.data['message'] ?? 'Server error',
          error.response?.statusCode ?? 500,
        );
      case DioExceptionType.cancel:
        return CancelledException('Request cancelled');
      default:
        return NetworkException('Network error: ${error.message}');
    }
  }
}

// Custom exceptions
class ServerException implements Exception {
  final String message;
  final int statusCode;

  ServerException(this.message, this.statusCode);

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class TimeoutException implements Exception {
  final String message;

  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}

class CancelledException implements Exception {
  final String message;

  CancelledException(this.message);

  @override
  String toString() => 'CancelledException: $message';
}
