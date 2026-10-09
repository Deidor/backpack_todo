import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'backpack_tool.dart';
import 'tool_preview_screen.dart';

/// Home screen: the backpack with one tappable object per tool.
class BackpackScreen extends StatelessWidget {
  const BackpackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
              ),
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                from: 30,
                child: const _Heading(),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FadeInUp(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  from: 60,
                  // Same proportions as mochila_back.png.
                  child: AspectRatio(
                    aspectRatio: 1024 / 1372,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final height =
                            constraints.maxHeight;
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
                              child: const _BackpackObject(
                                tool:
                                    BackpackTool.checklist,
                              ),
                            ),
                            Positioned(
                              left: width * 0.13,
                              top: height * 0.57,
                              width: width * 0.27,
                              child: const _BackpackObject(
                                tool: BackpackTool.stamps,
                              ),
                            ),
                            Positioned(
                              left: width * 0.50,
                              top: height * 0.57,
                              width: width * 0.34,
                              child: const _BackpackObject(
                                tool: BackpackTool.diary,
                              ),
                            ),
                            // Pocket fronts, drawn over the objects so that
                            // they look tucked in. Taps go through to the
                            // objects.
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
    return const Column(
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
          'Toca un objeto para sacarlo',
          style: TextStyle(
            fontFamily: AppFonts.button,
            fontSize: 15,
            color: AppColors.paper,
          ),
        ),
      ],
    );
  }
}

class _BackpackObject extends StatelessWidget {
  const _BackpackObject({required this.tool});

  final BackpackTool tool;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tool.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () =>
            Navigator.of(context)
                .push(ToolPreviewScreen.route(tool)),
        child: AspectRatio(
          aspectRatio: tool.aspectRatio,
          child: Image.asset(
            tool.asset,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
