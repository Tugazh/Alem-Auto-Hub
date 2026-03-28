import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../models/settings_models.dart';
import '../mock/mock_data.dart';

class SettingsService {
  final ApiClient _apiClient;

  SettingsService(this._apiClient);

  Future<SettingsModel> getSettings() async {
    try {
      final response = await _apiClient.get('/settings');
      return SettingsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to load settings: $e, using mock data');
      return MockData.mockSettings;
    }
  }

  Future<SettingsModel> updateNotifications(
    NotificationSettingsModel settings,
  ) async {
    try {
      final response = await _apiClient.post(
        '/settings/notifications',
        data: settings.toJson(),
      );
      return SettingsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to update notifications: $e, using mock data');
      final updated = MockData.mockSettings.copyWith(notifications: settings);
      MockData.mockSettings = updated;
      return updated;
    }
  }

  Future<SettingsModel> updateTwoFactor(bool enabled) async {
    try {
      final response = await _apiClient.post(
        '/settings/security/2fa',
        data: {'enabled': enabled},
      );
      return SettingsModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Failed to update 2FA: $e, using mock data');
      final updated = MockData.mockSettings.copyWith(
        security: MockData.mockSettings.security.copyWith(
          twoFactorEnabled: enabled,
        ),
      );
      MockData.mockSettings = updated;
      return updated;
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
      debugPrint('⚠️ Failed to change password: $e');
    }
  }
}
