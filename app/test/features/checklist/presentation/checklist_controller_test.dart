import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochila_peregrino/features/checklist/data/api_exception.dart';
import 'package:mochila_peregrino/features/checklist/data/items_providers.dart';
import 'package:mochila_peregrino/features/checklist/domain/item.dart';
import 'package:mochila_peregrino/features/checklist/presentation/checklist_controller.dart';
import 'package:mochila_peregrino/core/config/feature_flags.dart';

import '../fake_items_repository.dart';

void main() {
  const palos = Item(id: 1, name: 'Palos', packed: false, toBuy: false);
  const gorro = Item(id: 2, name: 'Gorro', packed: true, toBuy: false);

  late FakeItemsRepository repository;
  late ProviderContainer container;

  ChecklistController controller() =>
      container.read(checklistControllerProvider.notifier);
  List<Item> items() =>
      container.read(checklistControllerProvider).requireValue;

  setUp(() async {
    repository = FakeItemsRepository(items: [palos, gorro]);
    container = ProviderContainer(
      overrides: [itemsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    await container.read(checklistControllerProvider.future);
  });

  test('setPacked updates the item in the state and in the backend', () async {
    await controller().setPacked(palos, true);

    expect(items().first.packed, isTrue);
    expect(repository.items.first.packed, isTrue);
  });

  test('setToBuy does not touch the packed checkbox', () async {
    await controller().setToBuy(gorro, true);

    expect(items().last, gorro.copyWith(toBuy: true));
    expect(repository.items.last, gorro.copyWith(toBuy: true));
  });

  test(
    'setPacked restores the previous value when the request fails',
    () async {
      repository.failWrites = true;

      await expectLater(
        controller().setPacked(palos, true),
        throwsA(isA<ApiException>()),
      );

      expect(items().first.packed, isFalse);
    },
  );

  test('addItem appends the created item to the list', () async {
    await controller().addItem('Botas');

    expect(items().map((item) => item.name), ['Palos', 'Gorro', 'Botas']);
    expect(repository.items, hasLength(3));
  });

  test('addItem leaves the list untouched when the request fails', () async {
    repository.failWrites = true;

    await expectLater(
      controller().addItem('Botas'),
      throwsA(isA<ApiException>()),
    );

    expect(items(), [palos, gorro]);
  });

  test(
    'deleteItems removes the items from the state and the backend',
    () async {
      await controller().deleteItems([palos.id]);

      expect(items(), [gorro]);
      expect(repository.items, [gorro]);
    },
  );

  test(
    'deleteItems leaves the list untouched when the request fails',
    () async {
      repository.failWrites = true;

      await expectLater(
        controller().deleteItems([palos.id]),
        throwsA(isA<ApiException>()),
      );

      expect(items(), [palos, gorro]);
    },
  );

  group('exclusive checkboxes', () {
    setUp(() async {
      container = ProviderContainer(
        overrides: [
          itemsRepositoryProvider.overrideWithValue(repository),
          exclusiveCheckboxesProvider.overrideWithValue(true),
        ],
      );
      addTearDown(container.dispose);
      await container.read(checklistControllerProvider.future);
    });

    test('ticking "Comprar" unticks "Lo llevo"', () async {
      await controller().setToBuy(gorro, true);

      expect(items().last, gorro.copyWith(packed: false, toBuy: true));
      expect(repository.items.last, items().last);
    });

    test('ticking "Lo llevo" unticks "Comprar"', () async {
      await controller().setToBuy(palos, true);
      await controller().setPacked(items().first, true);

      expect(items().first, palos.copyWith(packed: true, toBuy: false));
      expect(repository.items.first, items().first);
    });

    test('unticking a checkbox leaves the other one alone', () async {
      await controller().setPacked(gorro, false);

      expect(items().last, gorro.copyWith(packed: false));
    });

    test('restores both checkboxes when the request fails', () async {
      repository.failWrites = true;

      await expectLater(
        controller().setToBuy(gorro, true),
        throwsA(isA<ApiException>()),
      );

      expect(items().last, gorro);
    });
  });
}
