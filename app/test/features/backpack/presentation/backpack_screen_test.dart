import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochila_peregrino/core/theme/app_theme.dart';
import 'package:mochila_peregrino/features/backpack/presentation/backpack_screen.dart';
import 'package:mochila_peregrino/features/checklist/data/items_providers.dart';
import 'package:mochila_peregrino/features/checklist/presentation/checklist_screen.dart';

import '../../checklist/fake_items_repository.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(FakeItemsRepository()),
        ],
        child: MaterialApp(theme: AppTheme.light, home: const BackpackScreen()),
      ),
    );
  }

  testWidgets('the notebook opens the checklist', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.bySemanticsLabel('Libreta'));
    await tester.pumpAndSettle();

    expect(find.byType(ChecklistScreen), findsOneWidget);
  });

  testWidgets('closing the checklist returns to the backpack', (tester) async {
    await pumpScreen(tester);
    await tester.tap(find.bySemanticsLabel('Libreta'));
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.byType(ChecklistScreen), findsNothing);
    expect(find.byType(BackpackScreen), findsOneWidget);
  });

  testWidgets('the other tools are announced as coming soon', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.bySemanticsLabel('Libro'));
    await tester.pump();
    expect(find.text('Próximamente'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Credencial'));
    await tester.pump();
    expect(find.text('Próximamente'), findsOneWidget);
  });
}
