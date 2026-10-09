import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class NotebookButton extends StatelessWidget {
  const NotebookButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor = Colors.white,
    this.foregroundColor = AppColors.ink,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(
          color: AppColors.ink,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppFonts.button,
                    fontSize: 14,
                    fontVariations: const [
                      FontVariation('wght', 600),
                    ],
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
