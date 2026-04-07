import 'package:flutter/material.dart';
import '../../core/network/api_client.dart';
import '../../data/cache/cache_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/garage_service.dart';
import '../../data/services/ai_service.dart';
import '../../data/services/market_service.dart';
import '../../data/services/social_service.dart';
import '../../data/services/maintenance_service.dart';
import '../../data/services/booking_service.dart';
import '../../data/services/fines_service.dart';
import '../../data/services/warehouse_service.dart';
import '../../data/services/cart_service.dart';
import '../../data/services/order_service.dart';
import '../../data/services/review_service.dart';
import '../../data/services/chat_service.dart';
import '../../data/services/community_service.dart';
import '../../data/services/search_service.dart';
import '../../data/services/finance_service.dart';

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
  late final BookingService _bookingService;
  late final FinesService _finesService;
  late final WarehouseService _warehouseService;
  late final CartService _cartService;
  late final OrderService _orderService;
  late final ReviewService _reviewService;
  late final ChatService _chatService;
  late final CommunityService _communityService;
  late final SearchService _searchService;
  late final FinanceService _financeService;

  bool _initialized = false;

  void _ensureInitialized() {
    if (!_initialized) {
      init();
    }
  }

  /// Инициализировать все сервисы.
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
    _bookingService = BookingService(_apiClient);
    _finesService = FinesService(_apiClient);
    _warehouseService = WarehouseService(_apiClient);
    _cartService = CartService(_apiClient);
    _orderService = OrderService(_apiClient);
    _reviewService = ReviewService(_apiClient);
    _chatService = ChatService(_apiClient);
    _communityService = CommunityService(_apiClient);
    _searchService = SearchService(_apiClient);
    _financeService = FinanceService(_apiClient);

    _initialized = true;
    debugPrint('Все сервисы успешно инициализированы');
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

  BookingService get bookingService {
    _ensureInitialized();
    return _bookingService;
  }

  FinesService get finesService {
    _ensureInitialized();
    return _finesService;
  }

  WarehouseService get warehouseService {
    _ensureInitialized();
    return _warehouseService;
  }

  CartService get cartService {
    _ensureInitialized();
    return _cartService;
  }

  OrderService get orderService {
    _ensureInitialized();
    return _orderService;
  }

  ReviewService get reviewService {
    _ensureInitialized();
    return _reviewService;
  }

  ChatService get chatService {
    _ensureInitialized();
    return _chatService;
  }

  CommunityService get communityService {
    _ensureInitialized();
    return _communityService;
  }

  SearchService get searchService {
    _ensureInitialized();
    return _searchService;
  }

  FinanceService get financeService {
    _ensureInitialized();
    return _financeService;
  }
}
