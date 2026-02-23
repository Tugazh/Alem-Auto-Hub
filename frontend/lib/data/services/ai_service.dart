import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

/// AI Service для работы с /api/v1/ai endpoints
///
/// Endpoints:
/// - POST /ai/chat - AI чат (OpenAI GPT-4o)
/// - POST /ai/analyze - Анализ данных
/// - POST /ai/recommend - Рекомендации
class AIService {
  final ApiClient _apiClient;

  static const String _fallbackMessage =
      'Сервис AI временно недоступен. Попробуйте чуть позже.';

  AIService(this._apiClient);

  /// Отправить сообщение в AI чат
  Future<Map<String, dynamic>> sendChatMessage({
    required String userId,
    required String message,
    List<Map<String, dynamic>>? history,
  }) async {
    try {
      final response = await _apiClient.post(
        '/agent/message',
        options: Options(validateStatus: (status) => status != null),
        data: {
          'user_id': userId,
          'message': message,
          if (history != null) 'history': history,
        },
      );

      if (response.statusCode == null || response.statusCode! >= 400) {
        return {'message': _buildMockReply(message), 'fallback': true};
      }

      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }

      return {'message': _fallbackMessage};
    } catch (e) {
      return {'message': _buildMockReply(message), 'fallback': true};
    }
  }

  String _buildMockReply(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('штраф')) {
      return 'Сейчас нет доступа к базе штрафов. Проверьте позже или уточните регион.';
    }
    if (normalized.contains('обслужив')) {
      return 'Я могу помочь с планом обслуживания. Укажите марку, модель и пробег.';
    }
    if (normalized.contains('проблем') || normalized.contains('диагност')) {
      return 'Опишите симптомы подробнее (звук, вибрация, когда возникает), и я помогу.';
    }
    return _fallbackMessage;
  }

  /// Анализ фото повреждений автомобиля
  Future<Map<String, dynamic>> analyzeDamage({
    required String imageBase64,
    String? carModel,
  }) async {
    final response = await _apiClient.post(
      '/ai/analyze',
      data: {
        'image': imageBase64,
        'type': 'damage',
        if (carModel != null) 'car_model': carModel,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Получить рекомендации по обслуживанию
  Future<List<Map<String, dynamic>>> getMaintenanceRecommendations({
    required String carModel,
    required int mileage,
    required int year,
  }) async {
    final response = await _apiClient.post(
      '/ai/recommend',
      data: {
        'car_model': carModel,
        'mileage': mileage,
        'year': year,
        'type': 'maintenance',
      },
    );

    return List<Map<String, dynamic>>.from(response.data);
  }

  /// Диагностика проблем по симптомам
  Future<Map<String, dynamic>> diagnoseProblem({
    required String symptoms,
    required String carModel,
  }) async {
    final response = await _apiClient.post(
      '/ai/analyze',
      data: {'symptoms': symptoms, 'car_model': carModel, 'type': 'diagnosis'},
    );

    return response.data as Map<String, dynamic>;
  }
}
