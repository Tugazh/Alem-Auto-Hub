import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/settings_models.dart';

class SettingsService {
  final ApiClient _apiClient;

  SettingsService(this._apiClient);

  Future<SettingsModel?> getSettings() async {
    try {
      final response = await _apiClient.get('/settings');
      return SettingsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось загрузить настройки: $e');
      return null;
    }
  }

  Future<SettingsModel?> updateNotifications(
    NotificationSettingsModel settings,
  ) async {
    try {
      final response = await _apiClient.post(
        '/settings/notifications',
        data: settings.toJson(),
      );
      return SettingsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось обновить уведомления: $e');
      return null;
    }
  }

  Future<SettingsModel?> updateTwoFactor(bool enabled) async {
    try {
      final response = await _apiClient.post(
        '/settings/security/2fa',
        data: {'enabled': enabled},
      );
      return SettingsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Не удалось обновить 2FA: $e');
      return null;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        '/settings/security/password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } catch (e) {
      debugPrint('Не удалось изменить пароль: $e');
    }
  }
}
