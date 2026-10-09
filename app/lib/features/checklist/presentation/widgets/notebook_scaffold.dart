import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Wooden background with the ring notebook on top. [body] is laid out on the
/// paper and [bottomBar] on the scroll drawn at the bottom of the artwork.
class NotebookScaffold extends StatelessWidget {
  const NotebookScaffold({
    super.key,
    required this.body,
    required this.bottomBar,
    this.onClose,
  });

  final Widget body;
  final Widget bottomBar;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/todo/fondo.png', fit: BoxFit.cover),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final height = constraints.maxHeight;
                  // Fractions measured on bloc.png.
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/todo/bloc.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        left: width * 0.06,
                        right: width * 0.06,
                        top: height * 0.16,
                        bottom: height * 0.13,
                        child: body,
                      ),
                      Positioned(
                        left: width * 0.09,
                        right: width * 0.09,
                        top: height * 0.895,
                        bottom: height * 0.03,
                        child: bottomBar,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(child: _CloseStrap(onPressed: onClose)),
          ),
        ],
      ),
    );
  }
}

class _CloseStrap extends StatelessWidget {
  const _CloseStrap({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -24,
            left: -8,
            width: 74,
            child: Image.asset('assets/todo/tirante.png'),
          ),
          Positioned(
            top: 34,
            left: 14,
            child: Semantics(
              button: true,
              label: 'Cerrar',
              child: GestureDetector(
                onTap: onPressed,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.ink, width: 2),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
