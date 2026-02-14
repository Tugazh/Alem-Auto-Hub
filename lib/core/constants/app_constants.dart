/// Константы для spacing, padding, margins
/// Используются во всем приложении для консистентности
class AppSpacing {
  // Private constructor
  AppSpacing._();

  // Standard spacing scale (8dp grid)
  static const double xs = 4.0; // Extra small
  static const double sm = 8.0; // Small
  static const double md = 12.0; // Medium
  static const double lg = 16.0; // Large
  static const double xl = 20.0; // Extra large
  static const double xxl = 24.0; // 2X large
  static const double xxxl = 32.0; // 3X large

  // Page padding
  static const double pagePadding = 16.0;
  static const double pageHorizontal = 16.0;
  static const double pageVertical = 12.0;

  // Card spacing
  static const double cardPadding = 16.0;
  static const double cardMargin = 12.0;
  static const double cardSpacing = 12.0;

  // Section spacing
  static const double sectionSpacing = 24.0;
  static const double blockSpacing = 16.0;

  // Bottom navigation compensation
  static const double bottomNavHeight = 80.0;
  static const double bottomSpace = 100.0;
}

/// Константы для border radius
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 9999.0; // Fully rounded

  // Specific components
  static const double button = 12.0;
  static const double card = 12.0;
  static const double input = 12.0;
  static const double dialog = 16.0;
  static const double bottomSheet = 20.0;
}

/// Константы для размеров UI элементов
class AppSizes {
  AppSizes._();

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Button heights
  static const double buttonSm = 40.0;
  static const double buttonMd = 48.0;
  static const double buttonLg = 56.0;

  // Input heights
  static const double inputHeight = 48.0;
  static const double inputHeightSm = 40.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // AppBar
  static const double appBarHeight = 56.0;

  // Bottom navigation
  static const double bottomNavHeight = 65.0;

  // Common component sizes
  static const double cardHeight = 60.0;
  static const double smallCardHeight = 56.0;
  static const double largeCardHeight = 120.0;

  // CarDetail specific
  static const double carImageHeight = 320.0;
  static const double podiumHeight = 200.0;
  static const double rotationButtonSize = 52.0;
  static const double checkboxSize = 24.0;
}

/// Константы для анимаций и transitions
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration dialogTransition = Duration(milliseconds: 250);
  static const Duration snackbar = Duration(seconds: 3);
}
