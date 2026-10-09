import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'backpack_tool.dart';

/// Intermediate step between the backpack and a tool: the object taken out
/// and shown large over the blurred backpack.
class ToolPreviewScreen extends StatelessWidget {
  const ToolPreviewScreen({super.key, required this.tool});

  final BackpackTool tool;

  /// Transparent route, so the backpack stays visible behind.
  static Route<void> route(BackpackTool tool) {
    return PageRouteBuilder<void>(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) =>
          ToolPreviewScreen(tool: tool),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  void _open(BuildContext context) {
    final builder = tool.screenBuilder;
    if (builder == null) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute<void>(builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = tool.screenBuilder != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Tapping outside the object puts it back.
        onTap: () => Navigator.of(context).pop(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            // Fills the screen so the dimming covers all of the backpack.
            constraints: const BoxConstraints.expand(),
            color: Colors.black45,
            child: SafeArea(
              minimum: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Flexible lets the object shrink on short screens.
                  Flexible(
                    child: ElasticIn(
                      duration: const Duration(milliseconds: 900),
                      child: Semantics(
                        button: isAvailable,
                        label: 'Abrir ${tool.label}',
                        child: GestureDetector(
                          onTap: isAvailable ? () => _open(context) : () {},
                          child: FractionallySizedBox(
                            widthFactor: 0.55,
                            child: AspectRatio(
                              aspectRatio: tool.aspectRatio,
                              child: Image.asset(
                                tool.asset,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    duration: const Duration(milliseconds: 400),
                    from: 20,
                    child: Column(
                      children: [
                        Text(
                          tool.title,
                          style: const TextStyle(
                            fontFamily: AppFonts.button,
                            fontSize: 24,
                            fontVariations: [FontVariation('wght', 600)],
                            color: AppColors.paper,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isAvailable ? 'Toca para abrir' : 'Próximamente',
                          style: const TextStyle(
                            fontFamily: AppFonts.button,
                            fontSize: 16,
                            color: AppColors.highlight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
