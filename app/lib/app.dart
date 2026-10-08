import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class PilgrimBackpackApp extends StatelessWidget {
  const PilgrimBackpackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Mochila del Peregrino',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const Scaffold(
        body: Center(
          child: Text('¿Lo llevo todo?', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
