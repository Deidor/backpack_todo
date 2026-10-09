import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/backpack/presentation/backpack_screen.dart';

class PilgrimBackpackApp extends StatelessWidget {
  const PilgrimBackpackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Mochila del Peregrino',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const BackpackScreen(),
    );
  }
}
