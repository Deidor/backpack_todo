import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochila_peregrino/core/theme/app_theme.dart';
import 'package:mochila_peregrino/features/backpack/presentation/backpack_screen.dart';
import 'package:mochila_peregrino/features/backpack/presentation/tool_preview_screen.dart';
import 'package:mochila_peregrino/features/checklist/data/items_providers.dart';
import 'package:mochila_peregrino/features/checklist/presentation/checklist_screen.dart';

import '../../checklist/fake_items_repository.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(FakeItemsRepository()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const BackpackScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> takeOut(WidgetTester tester, String label) async {
    await tester.tap(find.bySemanticsLabel(label));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping an object takes it out of the backpack', (tester) async {
    await pumpScreen(tester);

    await takeOut(tester, 'Libreta');

    expect(find.byType(ToolPreviewScreen), findsOneWidget);
    expect(find.text('¿Lo llevo todo?'), findsOneWidget);
    expect(find.text('Toca para abrir'), findsOneWidget);
  });

  testWidgets('tapping the notebook again opens the checklist', (tester) async {
    await pumpScreen(tester);
    await takeOut(tester, 'Libreta');

    await tester.tap(find.bySemanticsLabel('Abrir Libreta'));
    await tester.pumpAndSettle();

    expect(find.byType(ChecklistScreen), findsOneWidget);
    expect(find.byType(ToolPreviewScreen), findsNothing);
  });

  testWidgets('closing the checklist returns to the backpack', (tester) async {
    await pumpScreen(tester);
    await takeOut(tester, 'Libreta');
    await tester.tap(find.bySemanticsLabel('Abrir Libreta'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.byType(ChecklistScreen), findsNothing);
    expect(find.text('La Mochila'), findsOneWidget);
  });

  testWidgets('unavailable tools are shown as coming soon', (tester) async {
    await pumpScreen(tester);

    await takeOut(tester, 'Libro');

    expect(find.text('Próximamente'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Abrir Libro'));
    await tester.pumpAndSettle();

    expect(find.byType(ToolPreviewScreen), findsOneWidget);
  });

  testWidgets('tapping outside the object puts it back', (tester) async {
    await pumpScreen(tester);
    await takeOut(tester, 'Credencial');

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.byType(ToolPreviewScreen), findsNothing);
    expect(find.text('La Mochila'), findsOneWidget);
  });
}
