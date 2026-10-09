import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochila_peregrino/core/theme/app_theme.dart';
import 'package:mochila_peregrino/features/checklist/data/api_exception.dart';
import 'package:mochila_peregrino/features/checklist/data/items_providers.dart';
import 'package:mochila_peregrino/features/checklist/data/items_repository.dart';
import 'package:mochila_peregrino/features/checklist/domain/item.dart';
import 'package:mochila_peregrino/features/checklist/presentation/checklist_screen.dart';

import '../fake_items_repository.dart';

void main() {
  const palos = Item(id: 1, name: 'Palos', packed: true, toBuy: false);
  const gorro = Item(id: 2, name: 'Gorro', packed: false, toBuy: true);

  Future<void> pumpScreen(WidgetTester tester, ItemsRepository repository) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [itemsRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ChecklistScreen(),
        ),
      ),
    );
  }

  testWidgets('shows a loading indicator while items are being fetched', (
    tester,
  ) async {
    final pending = Completer<List<Item>>();
    await pumpScreen(
      tester,
      FakeItemsRepository(onFetch: () => pending.future),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.complete(const []);
    await tester.pumpAndSettle();
  });

  testWidgets('lists the items returned by the repository', (tester) async {
    await pumpScreen(tester, FakeItemsRepository(items: [palos, gorro]));
    await tester.pumpAndSettle();

    expect(find.text('¿LO LLEVO TODO?'), findsOneWidget);
    expect(find.text('PALOS'), findsOneWidget);
    expect(find.text('GORRO'), findsOneWidget);
  });

  testWidgets('shows the empty state when there are no items', (tester) async {
    await pumpScreen(tester, FakeItemsRepository());
    await tester.pumpAndSettle();

    expect(find.textContaining('Tu libreta está vacía'), findsOneWidget);
  });

  testWidgets('shows an error with a retry that reloads the list', (
    tester,
  ) async {
    var failing = true;
    final repository = FakeItemsRepository(
      onFetch: () async {
        if (failing) throw const ApiException();
        return const [palos];
      },
    );
    await pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    expect(find.textContaining('No se ha podido cargar'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('PALOS'), findsOneWidget);
    expect(find.textContaining('No se ha podido cargar'), findsNothing);
  });

  testWidgets('ticking a checkbox saves the change', (tester) async {
    final repository = FakeItemsRepository(items: [palos, gorro]);
    await pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Comprar: Palos'));
    await tester.pumpAndSettle();

    expect(repository.items.first, palos.copyWith(toBuy: true));
  });

  testWidgets('warns and reverts the checkbox when saving fails', (
    tester,
  ) async {
    final repository = FakeItemsRepository(items: [palos, gorro])
      ..failWrites = true;
    await pumpScreen(tester, repository);
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Lo llevo: Gorro'));
    await tester.pumpAndSettle();

    expect(find.text('No se ha podido guardar el cambio.'), findsOneWidget);
    expect(repository.items.last.packed, isFalse);
  });

  group('add item panel', () {
    Future<FakeItemsRepository> openPanel(WidgetTester tester) async {
      final repository = FakeItemsRepository(items: [palos]);
      await pumpScreen(tester, repository);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Añadir objeto'));
      await tester.pumpAndSettle();
      return repository;
    }

    testWidgets('creates the item and shows it in the list', (tester) async {
      final repository = await openPanel(tester);

      await tester.enterText(find.byType(TextField), '  Botas  ');
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('BOTAS'), findsOneWidget);
      expect(repository.items.last.name, 'Botas');
    });

    testWidgets('rejects an empty name and stays open', (tester) async {
      final repository = await openPanel(tester);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Añadir'));
      await tester.pumpAndSettle();

      expect(find.text('Escribe el nombre del objeto.'), findsOneWidget);
      expect(repository.items, hasLength(1));
    });

    testWidgets('cancel closes the panel without changes', (tester) async {
      final repository = await openPanel(tester);

      await tester.enterText(find.byType(TextField), 'Botas');
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.text('BOTAS'), findsNothing);
      expect(repository.items, hasLength(1));
    });
  });
}
