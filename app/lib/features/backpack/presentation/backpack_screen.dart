import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../checklist/presentation/checklist_screen.dart';

/// Home screen: the backpack with one tappable object per tool.
class BackpackScreen extends StatelessWidget {
  const BackpackScreen({super.key});

  void _openChecklist(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ChecklistScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Próximamente')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: _Heading(),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                // Same proportions as mochila_back.png.
                child: AspectRatio(
                  aspectRatio: 1024 / 1372,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final height = constraints.maxHeight;
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/backpack/mochila_back.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned(
                            left: width * 0.25,
                            top: height * 0.26,
                            width: width * 0.27,
                            child: _BackpackObject(
                              label: 'Libreta',
                              asset: 'assets/backpack/mochila_todo.png',
                              aspectRatio: 568 / 756,
                              onTap: () =>
                                  _openChecklist(context),
                            ),
                          ),
                          Positioned(
                            left: width * 0.13,
                            top: height * 0.57,
                            width: width * 0.27,
                            child: _BackpackObject(
                              label: 'Credencial',
                              asset: 'assets/backpack/mochila_sellos.png',
                              aspectRatio: 605 / 904,
                              onTap: () =>
                                  _showComingSoon(context),
                            ),
                          ),
                          Positioned(
                            left: width * 0.50,
                            top: height * 0.57,
                            width: width * 0.34,
                            child: _BackpackObject(
                              label: 'Libro',
                              asset: 'assets/backpack/mochila_diario.png',
                              aspectRatio: 732 / 880,
                              onTap: () =>
                                  _showComingSoon(context),
                            ),
                          ),
                          // Pocket fronts, drawn over the objects so that they
                          // look tucked in. Taps go through to the objects.
                          Positioned(
                            left: width * 0.018,
                            bottom: 0,
                            width: width * 0.965,
                            child: IgnorePointer(
                              child: Image.asset(
                                'assets/backpack/mochila_front.png',
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'La Mochila',
            style: TextStyle(
              fontFamily: AppFonts.button,
              fontSize: 30,
              fontVariations: [FontVariation('wght', 600)],
              color: AppColors.paper,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Toca un objeto para abrirlo',
            style: TextStyle(
              fontFamily: AppFonts.button,
              fontSize: 15,
              color: AppColors.paper,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackpackObject extends StatelessWidget {
  const _BackpackObject({
    required this.label,
    required this.asset,
    required this.aspectRatio,
    required this.onTap,
  });

  final String label;
  final String asset;

  /// Width / height of the image, so it takes its place before it loads.
  final double aspectRatio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.asset(asset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
