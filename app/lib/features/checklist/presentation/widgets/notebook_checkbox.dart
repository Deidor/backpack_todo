import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class NotebookCheckbox extends StatefulWidget {
  const NotebookCheckbox({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.mark = Icons.check_rounded,
    this.fillColor = AppColors.check,
    this.markColor = AppColors.checkMark,
  });

  static const double size = 30;

  final bool value;
  final String label;
  final ValueChanged<bool>? onChanged;
  final IconData mark;
  final Color fillColor;
  final Color markColor;

  @override
  State<NotebookCheckbox> createState() => _NotebookCheckboxState();
}

class _NotebookCheckboxState extends State<NotebookCheckbox> {
  static const double _size = NotebookCheckbox.size;

  AnimationController? _pulse;

  @override
  void didUpdateWidget(NotebookCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only when it gets ticked, not when the row is first shown.
    if (widget.value && !oldWidget.value) _pulse?.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final onChanged = widget.onChanged;
    return Semantics(
      checked: value,
      label: widget.label,
      child: InkResponse(
        onTap: onChanged == null ? null : () => onChanged(!value),
        radius: _size,
        child: Pulse(
          manualTrigger: true,
          duration: const Duration(milliseconds: 300),
          to: 1.25,
          controller: (controller) => _pulse = controller,
          child: SizedBox.square(
            dimension: _size + 8,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                if (value)
                  Container(
                    width: _size - 6,
                    height: _size - 7,
                    decoration: BoxDecoration(
                      color: widget.fillColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                Image.asset(
                  'assets/todo/cuadrado.png',
                  width: _size,
                  height: _size,
                  fit: BoxFit.fill,
                ),
                if (value)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Icon(
                      widget.mark,
                      size: _size + 4,
                      color: widget.markColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
