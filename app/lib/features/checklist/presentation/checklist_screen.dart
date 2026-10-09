import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/feature_flags.dart';
import '../../../core/theme/app_colors.dart';
import '../data/api_exception.dart';
import '../domain/item.dart';
import 'checklist_controller.dart';
import 'edit_mode_controller.dart';
import 'widgets/add_item_sheet.dart';
import 'widgets/item_row.dart';
import 'widgets/notebook_button.dart';
import 'widgets/notebook_scaffold.dart';

import 'package:animate_do/animate_do.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checklistControllerProvider);
    final controller = ref.read(checklistControllerProvider.notifier);
    final pendingDeletions = ref.watch(editModeProvider);
    final editMode = ref.read(editModeProvider.notifier);
    final isEditing = pendingDeletions != null;
    final exclusiveMode = ref.watch(exclusiveCheckboxesProvider);

    return NotebookScaffold(
      onClose: () => Navigator.of(context).maybePop(),
      body: Column(
        children: [
          Text(
            '¿LO LLEVO TODO?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          _ColumnHeaders(buyFirst: exclusiveMode),
          Expanded(
            child: _ChecklistBody(
              items: items,
              hiddenIds: pendingDeletions ?? const {},
              exclusiveMode: ref.watch(exclusiveCheckboxesProvider),
              onRetry: controller.reload,
              // Checkboxes are locked while editing so that cancelling
              // leaves everything untouched.
              onPackedChanged: isEditing
                  ? null
                  : (item, value) =>
                        _save(context, () => controller.setPacked(item, value)),
              onToBuyChanged: isEditing
                  ? null
                  : (item, value) =>
                        _save(context, () => controller.setToBuy(item, value)),
              onDelete: isEditing
                  ? (item) => editMode.markForDeletion(item.id)
                  : null,
            ),
          ),
        ],
      ),
      bottomBar: isEditing
          ? Row(
              children: [
                Expanded(
                  child: NotebookButton(
                    label: 'Cancelar',
                    backgroundColor: AppColors.danger,
                    foregroundColor: AppColors.onDanger,
                    borderColor: AppColors.dangerBorder,
                    onPressed: editMode.stop,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NotebookButton(
                    label: 'Guardar cambios',
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    borderColor: AppColors.accentBorder,
                    onPressed: () => _saveDeletions(
                      context,
                      controller,
                      editMode,
                      pendingDeletions,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NotebookButton(
                    label: 'Añadir objeto',
                    icon: const _AddIcon(),
                    onPressed: items.hasValue
                        ? () => _addItem(context, controller)
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: NotebookButton(
                    label: 'Editar',
                    onPressed: items.value?.isNotEmpty ?? false
                        ? editMode.start
                        : null,
                  ),
                ),
              ],
            ),
    );
  }
}

Future<void> _addItem(
  BuildContext context,
  ChecklistController controller,
) async {
  final name = await AddItemSheet.show(context);
  if (name == null || !context.mounted) return;
  await _save(context, () => controller.addItem(name));
}

Future<void> _saveDeletions(
  BuildContext context,
  ChecklistController controller,
  EditModeController editMode,
  Set<int> ids,
) async {
  if (ids.isNotEmpty) {
    final saved = await _save(
      context,
      () => controller.deleteItems(ids.toList()),
    );
    // Stay in edit mode so the pending deletions are not lost.
    if (!saved) return;
  }
  editMode.stop();
}

/// Runs [action] and reports whether it succeeded, warning the user if not.
Future<bool> _save(BuildContext context, Future<void> Function() action) async {
  try {
    await action();
    return true;
  } on ApiException {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('No se ha podido guardar el cambio.')),
        );
    }
    return false;
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders({required this.buyFirst});

  final bool buyFirst;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    final packed = SizedBox(
      width: checkColumnWidth,
      child: Text('LO LLEVO?', textAlign: TextAlign.center, style: style),
    );
    final toBuy = SizedBox(
      width: checkColumnWidth,
      child: Text('COMPRAR', textAlign: TextAlign.center, style: style),
    );
    return Row(
      children: [
        Expanded(
          child: Text('OBJETO', style: Theme.of(context).textTheme.bodyMedium),
        ),
        if (buyFirst) ...[toBuy, packed] else ...[packed, toBuy],
      ],
    );
  }
}

class _ChecklistBody extends StatelessWidget {
  const _ChecklistBody({
    required this.items,
    required this.hiddenIds,
    required this.exclusiveMode,
    required this.onRetry,
    required this.onPackedChanged,
    required this.onToBuyChanged,
    required this.onDelete,
  });

  final AsyncValue<List<Item>> items;
  final Set<int> hiddenIds;
  final bool exclusiveMode;
  final VoidCallback onRetry;
  final void Function(Item item, bool value)? onPackedChanged;
  final void Function(Item item, bool value)? onToBuyChanged;
  final void Function(Item item)? onDelete;

  @override
  Widget build(BuildContext context) {
    final value = items.value;
    if (value == null) {
      if (items.isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.ink),
        );
      }
      return _Message(
        text: 'No se ha podido cargar la libreta.\nRevisa tu conexión.',
        action: NotebookButton(label: 'Reintentar', onPressed: onRetry),
      );
    }
    if (value.isEmpty) {
      return const _Message(
        text: 'Tu libreta está vacía.\nAñade tu primer objeto.',
      );
    }
    final visible = [
      for (final item in value)
        if (!hiddenIds.contains(item.id)) item,
    ];
    final onPackedChanged = this.onPackedChanged;
    final onToBuyChanged = this.onToBuyChanged;
    final onDelete = this.onDelete;
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final item = visible[index];
        // Keyed by id so that a row only slides in when it first appears.
        return FadeInLeft(
          key: ValueKey(item.id),
          duration: const Duration(milliseconds: 300),
          from: 24,
          child: ItemRow(
            item: item,
            onPackedChanged: onPackedChanged == null
                ? null
                : (value) => onPackedChanged(item, value),
            onToBuyChanged: onToBuyChanged == null
                ? null
                : (value) => onToBuyChanged(item, value),
            onDelete: onDelete == null ? null : () => onDelete(item),
            exclusiveMode: exclusiveMode,
          ),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

class _AddIcon extends StatelessWidget {
  const _AddIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.addIcon,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: const Icon(Icons.add, size: 16, color: Colors.white),
    );
  }
}
