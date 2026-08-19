import 'package:file_reader/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const colors = AppColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Archivo',
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        secondary: colors.primaryLight,
        surface: colors.surface,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colors.surface,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 14,
          color: colors.textSecondary,
        ),
      ),
      extensions: const [colors],
    );
  }

  static ThemeData get darkTheme {
    const colors = AppColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Archivo',
      scaffoldBackgroundColor: colors.background,
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        secondary: colors.primaryLight,
        surface: colors.surface,
        error: colors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: colors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardTheme(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: colors.surfaceElevated,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.border, width: 1),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Archivo',
          fontSize: 14,
          color: colors.textSecondary,
        ),
      ),
      extensions: const [colors],
    );
  }
}
