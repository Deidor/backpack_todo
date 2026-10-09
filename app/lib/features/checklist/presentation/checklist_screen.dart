import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/item.dart';
import 'checklist_controller.dart';
import 'widgets/item_row.dart';
import 'widgets/notebook_button.dart';
import 'widgets/notebook_scaffold.dart';

class ChecklistScreen extends ConsumerWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(checklistControllerProvider);

    return NotebookScaffold(
      onClose: () => Navigator.of(context).maybePop(),
      body: Column(
        children: [
          Text(
            '¿LO LLEVO TODO?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const _ColumnHeaders(),
          Expanded(
            child: _ChecklistBody(
              items: items,
              onRetry: ref.read(checklistControllerProvider.notifier).reload,
            ),
          ),
        ],
      ),
      bottomBar: Row(
        children: [
          Expanded(
            flex: 3,
            child: NotebookButton(
              label: 'Añadir objeto',
              icon: const _AddIcon(),
              onPressed: null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: NotebookButton(label: 'Editar', onPressed: null),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Row(
      children: [
        Expanded(
          child: Text('OBJETO', style: Theme.of(context).textTheme.bodyMedium),
        ),
        SizedBox(
          width: checkColumnWidth,
          child: Text('LO LLEVO?', textAlign: TextAlign.center, style: style),
        ),
        SizedBox(
          width: checkColumnWidth,
          child: Text('COMPRAR', textAlign: TextAlign.center, style: style),
        ),
      ],
    );
  }
}

class _ChecklistBody extends StatelessWidget {
  const _ChecklistBody({required this.items, required this.onRetry});

  final AsyncValue<List<Item>> items;
  final VoidCallback onRetry;

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
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: value.length,
      itemBuilder: (context, index) {
        final item = value[index];
        return ItemRow(key: ValueKey(item.id), item: item);
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
        color: AppColors.highlight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: const Icon(Icons.add, size: 16, color: Colors.white),
    );
  }
}
