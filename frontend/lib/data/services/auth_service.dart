import '../../core/network/api_client.dart';

/// Auth Service для работы с /api/v1/auth endpoints
///
/// Endpoints:
/// - POST /auth/register - Регистрация
/// - POST /auth/login - Вход
/// - POST /auth/refresh - Обновление токена
/// - POST /auth/logout - Выход
/// - GET /auth/verify - Проверка токена
class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  /// Регистрация нового пользователя
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  /// Вход пользователя
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    // TODO: Сохранить JWT token в SecureStorage
    // final token = response.data['token'];
    // await SecureStorage.saveToken(token);

    return response.data as Map<String, dynamic>;
  }

  /// Обновление токена
  Future<Map<String, dynamic>> refreshToken() async {
    final response = await _apiClient.post('/auth/refresh');

    // TODO: Обновить JWT token в SecureStorage
    // final token = response.data['token'];
    // await SecureStorage.saveToken(token);

    return response.data as Map<String, dynamic>;
  }

  /// Выход пользователя
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');

    // TODO: Удалить JWT token из SecureStorage
    // await SecureStorage.deleteToken();
  }

  /// Проверка токена
  Future<bool> verifyToken() async {
    try {
      final response = await _apiClient.get('/auth/verify');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
