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
      seedColor: AppColors.accentBorder,
      surface: AppColors.paper,
      error: AppColors.danger,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1,
        color: AppColors.heading,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.itemText,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: AppColors.heading,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        color: AppColors.heading,
      ),
    ),
  );
}
