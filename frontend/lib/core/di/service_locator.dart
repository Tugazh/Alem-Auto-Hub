import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../data/cache/cache_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/garage_service.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/market_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/maintenance_service.dart';

/// Service Locator для управления зависимостями
///
/// Singleton pattern для централизованного управления сервисами
/// В production можно заменить на GetIt или Riverpod
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() => _instance;

  ServiceLocator._internal();

  // Singleton instances
  late final ApiClient _apiClient;
  late final CacheService _cacheService;
  late final AuthService _authService;
  late final GarageService _garageService;
  late final AIService _aiService;
  late final MarketService _marketService;
  late final SocialService _socialService;
  late final MaintenanceService _maintenanceService;

  bool _initialized = false;

  void _ensureInitialized() {
    if (!_initialized) {
      init();
    }
  }

  /// Initialize all services
  void init() {
    if (_initialized) return;

    // Core
    _apiClient = ApiClient();
    _cacheService = CacheService();

    // Services
    _authService = AuthService(_apiClient);
    _garageService = GarageService(_apiClient, _cacheService);
    _aiService = AIService(_apiClient);
    _marketService = MarketService(_apiClient);
    _socialService = SocialService(_apiClient);
    _maintenanceService = MaintenanceService(_apiClient, _cacheService);

    _initialized = true;
    debugPrint('✅ All services initialized successfully');
  }

  // Getters
  ApiClient get apiClient {
    _ensureInitialized();
    return _apiClient;
  }

  CacheService get cacheService {
    _ensureInitialized();
    return _cacheService;
  }

  AuthService get authService {
    _ensureInitialized();
    return _authService;
  }

  GarageService get garageService {
    _ensureInitialized();
    return _garageService;
  }

  AIService get aiService {
    _ensureInitialized();
    return _aiService;
  }

  MarketService get marketService {
    _ensureInitialized();
    return _marketService;
  }

  SocialService get socialService {
    _ensureInitialized();
    return _socialService;
  }

  MaintenanceService get maintenanceService {
    _ensureInitialized();
    return _maintenanceService;
  }
}
