import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Features
import '../../features/home/home_page.dart';
import '../../features/booking/booking_page.dart';
import '../../features/market/market_page.dart';
import '../../features/social/social_page.dart';
import '../../features/ai_agent/ai_agent_page.dart';
import '../../features/finance/finance_page.dart';
import '../../features/warehouse/warehouse_page.dart';

/// Centralized router configuration with type-safe navigation
///
/// Features:
/// - Named routes with constants
/// - Deep linking support
/// - Navigation guards
/// - Smooth transitions
/// - Error handling with 404 page
class AppRouter {
  // Route names (constants for type-safety)
  static const String home = '/';
  static const String booking = '/booking';
  static const String market = '/market';
  static const String social = '/social';
  static const String aiAgent = '/ai-agent';
  static const String finance = '/finance';
  static const String warehouse = '/warehouse';

  /// Router instance (singleton pattern)
  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => _ErrorPage(error: state.error),
    routes: [
      // Home route
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          // Booking routes
          GoRoute(
            path: 'booking',
            name: 'booking',
            builder: (context, state) => const BookingPage(),
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const BookingPage(),
            ),
          ),

          // Market routes
          GoRoute(
            path: 'market',
            name: 'market',
            builder: (context, state) => const MarketPage(),
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const MarketPage(),
            ),
          ),

          // Social routes
          GoRoute(
            path: 'social',
            name: 'social',
            builder: (context, state) => const SocialPage(),
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const SocialPage(),
            ),
          ),

          // AI Agent routes
          GoRoute(
            path: 'ai-agent',
            name: 'ai-agent',
            builder: (context, state) => const AIAgentPage(),
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const AIAgentPage(),
            ),
          ),

          // Finance routes
          GoRoute(
            path: 'finance',
            name: 'finance',
            builder: (context, state) => const FinancePage(),
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const FinancePage(),
            ),
          ),

          // Warehouse routes
          GoRoute(
            path: 'warehouse',
            name: 'warehouse',
            builder: (context, state) => const WarehousePage(),
            pageBuilder: (context, state) => _buildPageWithTransition(
              context: context,
              state: state,
              child: const WarehousePage(),
            ),
          ),
        ],
      ),
    ],

    // Navigation guard (redirect logic)
    redirect: (context, state) {
      // Add authentication check here if needed
      // Example:
      // final isAuthenticated = authService.isAuthenticated;
      // if (!isAuthenticated && state.matchedLocation != '/login') {
      //   return '/login';
      // }
      return null; // No redirect
    },
  );

  /// Build page with custom transition animation
  static CustomTransitionPage _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition from right
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }
}

/// Error page (404)
class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ошибка'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRouter.home),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Страница не найдена',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRouter.home),
              icon: const Icon(Icons.home),
              label: const Text('На главную'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension methods for type-safe navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to home
  void goHome() => go(AppRouter.home);

  /// Navigate to booking
  void goBooking() => go(AppRouter.booking);

  /// Navigate to market
  void goMarket() => go(AppRouter.market);

  /// Navigate to social
  void goSocial() => go(AppRouter.social);

  /// Navigate to AI Agent
  void goAIAgent() => go(AppRouter.aiAgent);

  /// Navigate to finance
  void goFinance() => go(AppRouter.finance);

  /// Navigate to warehouse
  void goWarehouse() => go(AppRouter.warehouse);
}
