import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSecondary;
  final Color border;
  final Color divider;
  final Color primary;
  final Color primaryLight;
  final Color primaryGradientStart;
  final Color primaryGradientEnd;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color success;
  final Color error;
  final Color warning;
  final Color topBarBg;
  final Color bottomNavBg;
  final Color bottomNavBorder;
  final Color cardShadow;

  const AppColors({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSecondary,
    required this.border,
    required this.divider,
    required this.primary,
    required this.primaryLight,
    required this.primaryGradientStart,
    required this.primaryGradientEnd,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.success,
    required this.error,
    required this.warning,
    required this.topBarBg,
    required this.bottomNavBg,
    required this.bottomNavBorder,
    required this.cardShadow,
  });

  /// Dark Theme semantic colors (derived from visual reference screenshot)
  static const dark = AppColors(
    isDark: true,
    background: Color(0xFF111217),
    surface: Color(0xFF191B29),
    surfaceElevated: Color(0xFF1E2030),
    surfaceSecondary: Color(0xFF222538),
    border: Color(0xFF26293D),
    divider: Color(0xFF222538),
    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFF3B82F6),
    primaryGradientStart: Color(0xFF2563EB),
    primaryGradientEnd: Color(0xFF1D4ED8),
    textPrimary: Color(0xFFF5F7FA),
    textSecondary: Color(0xFF9AA4B8),
    textDisabled: Color(0xFF5A6275),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    topBarBg: Color(0xFF111217),
    bottomNavBg: Color(0xD9191B29), // Translucent dark navy
    bottomNavBorder: Color(0xFF26293D),
    cardShadow: Color(0x20000000),
  );

  /// Light Theme semantic colors (preserves existing light styling)
  static const light = AppColors(
    isDark: false,
    background: Color(0xFFF2F3F7),
    surface: Colors.white,
    surfaceElevated: Color(0xFFF9FAFC),
    surfaceSecondary: Color(0xFFF0EFFE),
    border: Color(0xFFE5E7EB),
    divider: Color(0xFFF3F4F6),
    primary: Color(0xFF5B5CFF),
    primaryLight: Color(0xFF7C7DFF),
    primaryGradientStart: Color(0xFF5B5CFF),
    primaryGradientEnd: Color(0xFF4A4FE8),
    textPrimary: Color(0xFF1A1A2E),
    textSecondary: Color(0xFF9CA3AF),
    textDisabled: Color(0xFFD1D5DB),
    success: Color(0xFF10B981),
    error: Color(0xFFEF4444),
    warning: Color(0xFFF59E0B),
    topBarBg: Color.fromARGB(120, 255, 246, 246),
    bottomNavBg: Color(0x40FFFFFF),
    bottomNavBorder: Color(0x66FFFFFF),
    cardShadow: Color(0x10000000),
  );

  @override
  ThemeExtension<AppColors> copyWith({
    bool? isDark,
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSecondary,
    Color? border,
    Color? divider,
    Color? primary,
    Color? primaryLight,
    Color? primaryGradientStart,
    Color? primaryGradientEnd,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? success,
    Color? error,
    Color? warning,
    Color? topBarBg,
    Color? bottomNavBg,
    Color? bottomNavBorder,
    Color? cardShadow,
  }) {
    return AppColors(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryGradientStart: primaryGradientStart ?? this.primaryGradientStart,
      primaryGradientEnd: primaryGradientEnd ?? this.primaryGradientEnd,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      topBarBg: topBarBg ?? this.topBarBg,
      bottomNavBg: bottomNavBg ?? this.bottomNavBg,
      bottomNavBorder: bottomNavBorder ?? this.bottomNavBorder,
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) return this;
    return AppColors(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryGradientStart: Color.lerp(primaryGradientStart, other.primaryGradientStart, t)!,
      primaryGradientEnd: Color.lerp(primaryGradientEnd, other.primaryGradientEnd, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      topBarBg: Color.lerp(topBarBg, other.topBarBg, t)!,
      bottomNavBg: Color.lerp(bottomNavBg, other.bottomNavBg, t)!,
      bottomNavBorder: Color.lerp(bottomNavBorder, other.bottomNavBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
    );
  }
}

extension BuildContextThemeExtension on BuildContext {
  AppColors get colors {
    return Theme.of(this).extension<AppColors>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? AppColors.dark
            : AppColors.light);
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
