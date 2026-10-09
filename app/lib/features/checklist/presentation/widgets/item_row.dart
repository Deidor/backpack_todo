import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/item.dart';
import 'notebook_checkbox.dart';

/// Width of each checkbox column, shared with the header row.
const double checkColumnWidth = 58;

class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.item,
    this.onPackedChanged,
    this.onToBuyChanged,
    this.onDelete,
    this.exclusiveMode = false,
  });

  final Item item;
  final ValueChanged<bool>? onPackedChanged;
  final ValueChanged<bool>? onToBuyChanged;

  /// Shows the red delete button when set.
  final VoidCallback? onDelete;

  /// Alternative layout: "Comprar" comes first and has its own mark.
  final bool exclusiveMode;

  @override
  Widget build(BuildContext context) {
    final packedBox = SizedBox(
      width: checkColumnWidth,
      child: Center(
        child: NotebookCheckbox(
          value: item.packed,
          label: 'Lo llevo: ${item.name}',
          onChanged: onPackedChanged,
        ),
      ),
    );
    final toBuyBox = SizedBox(
      width: checkColumnWidth,
      child: Center(
        child: NotebookCheckbox(
          value: item.toBuy,
          label: 'Comprar: ${item.name}',
          onChanged: onToBuyChanged,
          mark: exclusiveMode
              ? Icons.shopping_cart_rounded
              : Icons.check_rounded,
          fillColor: exclusiveMode ? AppColors.highlight : AppColors.check,
          markColor: exclusiveMode ? AppColors.ink : AppColors.checkMark,
        ),
      ),
    );

    return SizedBox(
      height: 46,
      child: Row(
        children: [
          if (onDelete != null)
            _DeleteButton(name: item.name, onPressed: onDelete!),
          Expanded(child: _DottedName(name: item.name)),
          if (exclusiveMode) ...[
            toBuyBox,
            packedBox,
          ] else ...[
            packedBox,
            toBuyBox,
          ],
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Eliminar: $name',
      child: InkResponse(
        onTap: onPressed,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.delete,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.itemText, width: 1.5),
            ),
            child: const Icon(Icons.remove, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _DottedName extends StatelessWidget {
  const _DottedName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ConstrainedBox(
              // Always leaves room for a short piece of dotted line.
              constraints: BoxConstraints(maxWidth: constraints.maxWidth - 16),
              child: Text(
                name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5, right: 4),
                child: Image.asset(
                  'assets/todo/linea_puntos.png',
                  height: 4,
                  repeat: ImageRepeat.repeatX,
                  fit: BoxFit.fitHeight,
                  alignment: Alignment.centerLeft,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
