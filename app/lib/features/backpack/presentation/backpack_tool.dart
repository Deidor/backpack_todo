import 'package:flutter/widgets.dart';

import '../../checklist/presentation/checklist_screen.dart';

/// One of the objects kept in the backpack.
class BackpackTool {
  const BackpackTool({
    required this.label,
    required this.title,
    required this.asset,
    required this.aspectRatio,
    this.screenBuilder,
  });

  /// Short name, used for accessibility.
  final String label;

  /// Name shown under the object when it is taken out.
  final String title;

  final String asset;

  /// Width / height of the image, so it takes its place before it loads.
  final double aspectRatio;

  /// Builds the screen of the tool. Null while the tool is not available.
  final WidgetBuilder? screenBuilder;

  static const BackpackTool checklist = BackpackTool(
    label: 'Libreta',
    title: '¿Lo llevo todo?',
    asset: 'assets/backpack/mochila_todo.png',
    aspectRatio: 568 / 756,
    screenBuilder: _buildChecklist,
  );

  static const BackpackTool diary = BackpackTool(
    label: 'Libro',
    title: 'Libro',
    asset: 'assets/backpack/mochila_diario.png',
    aspectRatio: 732 / 880,
  );

  static const BackpackTool stamps = BackpackTool(
    label: 'Credencial',
    title: 'Credencial',
    asset: 'assets/backpack/mochila_sellos.png',
    aspectRatio: 605 / 904,
  );
}

Widget _buildChecklist(BuildContext context) => const ChecklistScreen();
