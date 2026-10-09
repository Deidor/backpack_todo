import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mochila_peregrino/features/checklist/data/api_exception.dart';
import 'package:mochila_peregrino/features/checklist/data/items_providers.dart';
import 'package:mochila_peregrino/features/checklist/domain/item.dart';
import 'package:mochila_peregrino/features/checklist/presentation/checklist_controller.dart';

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
}
