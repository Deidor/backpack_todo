import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NotebookCheckbox extends StatelessWidget {
  const NotebookCheckbox({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
  });

  static const double size = 30;

  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: value,
      label: label,
      child: InkResponse(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        radius: size,
        child: SizedBox.square(
          dimension: size + 8,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (value)
                Container(
                  width: size - 6,
                  height: size - 7,
                  decoration: BoxDecoration(
                    color: AppColors.check,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              Image.asset(
                'assets/todo/cuadrado.png',
                width: size,
                height: size,
                fit: BoxFit.fill,
              ),
              if (value)
                const Positioned(
                  top: -2,
                  right: -2,
                  child: Icon(
                    Icons.check_rounded,
                    size: size + 4,
                    color: AppColors.checkMark,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
