import 'package:flutter/material.dart';

/// Централизованная цветовая схема приложения
/// Все цвета соответствуют Material Design 3 Dark Theme
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFFF5722); // Orange/Red accent
  static const Color primaryDark = Color(0xFFE64A19); // Darker variant
  static const Color primaryLight = Color(0xFFFF8A65); // Lighter variant

  // Background Colors
  static const Color background = Color(
    0xFF1A1A1A,
  ); // Main background (almost black)
  static const Color surface = Color(0xFF2A2A2A); // Card/widget surface
  static const Color cardBackground = Color(0xFF252525); // Alternative card bg
  static const Color bottomNavBackground = Color(0xFF2A2A2A); // Bottom nav

  // Specific UI Element Colors
  static const Color carDetailCard = Color(0xFF27292F); // CarDetailPage cards

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // Main text (white)
  static const Color textSecondary = Color(0xFF999999); // Secondary text (gray)
  static const Color textTertiary = Color(0xFF666666); // Tertiary/disabled
  static const Color textLabel = Color(0xFF8B92A3); // Labels in forms

  // Status/Notification Colors
  static const Color error = Color(0xFFFF3B30); // Error/red notification
  static const Color warning = Color(0xFFFFCC00); // Warning/yellow notification
  static const Color success = Color(0xFF34C759); // Success/green notification
  static const Color info = Color(0xFF007AFF); // Info/blue

  // UI Elements
  static const Color divider = Color(0xFF3A3A3A); // Dividers and borders
  static const Color iconGray = Color(0xFF666666); // Inactive icons
  static const Color selectedBorder = Color(0xFFFF5722); // Selected item border
  static const Color shimmer = Color(0xFF3A3A3A); // Loading shimmer effect

  // Overlay and Modals
  static const Color overlay = Color(0x80000000); // Semi-transparent black
  static const Color modalBackground = Color(0xFF2A2A2A); // Modal bg

  // Button States
  static const Color buttonDisabled = Color(0xFF3A3A3A); // Disabled button
  static const Color buttonHover = Color(0xFFE64A19); // Button hover state

  // Input Fields
  static const Color inputBackground = Color(0xFF2A2A2A); // Text input bg
  static const Color inputBorder = Color(0xFF3A3A3A); // Input border
  static const Color inputFocused = Color(0xFFFF5722); // Focused input

  // Chart Colors (для финансовых графиков)
  static const Color chartRed = Color(0xFFFF3B30);
  static const Color chartGreen = Color(0xFF34C759);
  static const Color chartBlue = Color(0xFF007AFF);
  static const Color chartOrange = Color(0xFFFF9500);
  static const Color chartPurple = Color(0xFFAF52DE);
}
