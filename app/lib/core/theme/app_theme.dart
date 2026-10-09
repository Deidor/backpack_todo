import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppFonts {
  static const String notebook = 'SpecialElite';
  static const String button = 'Fredoka';
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.wood,
    fontFamily: AppFonts.notebook,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.check,
      surface: AppColors.paper,
      error: AppColors.danger,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 22,
        color: AppColors.ink,
        letterSpacing: 1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: AppColors.ink,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        color: AppColors.ink,
      ),
    ),
  );
}
