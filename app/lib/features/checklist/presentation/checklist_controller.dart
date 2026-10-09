import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_exception.dart';
import '../data/items_providers.dart';
import '../data/items_repository.dart';
import '../domain/item.dart';

final checklistControllerProvider =
    AsyncNotifierProvider<ChecklistController, List<Item>>(
      ChecklistController.new,
      // The error state offers a manual retry instead.
      retry: (retryCount, error) => null,
    );

class ChecklistController
    extends AsyncNotifier<List<Item>> {
  ItemsRepository get _repository =>
      ref.read(itemsRepositoryProvider);

  @override
  Future<List<Item>> build() {
    return ref.watch(itemsRepositoryProvider).fetchItems();
  }

  void reload() => ref.invalidateSelf();

  Future<void> setPacked(Item item, bool value) async {
    _replace(
      item.id,
      (current) => current.copyWith(packed: value),
    );
    try {
      await _repository.updateItem(item.id, packed: value);
    } on ApiException {
      _replace(
        item.id,
        (current) => current.copyWith(packed: !value),
      );
      rethrow;
    }
  }

  Future<void> setToBuy(Item item, bool value) async {
    _replace(
      item.id,
      (current) => current.copyWith(toBuy: value),
    );
    try {
      await _repository.updateItem(item.id, toBuy: value);
    } on ApiException {
      _replace(
        item.id,
        (current) => current.copyWith(toBuy: !value),
      );
      rethrow;
    }
  }

  Future<void> addItem(String name) async {
    final created = await _repository.createItem(name);
    state = AsyncData([...?state.value, created]);
  }

  Future<void> deleteItems(List<int> ids) async {
    await _repository.deleteItems(ids);
    state = AsyncData([
      for (final item in state.value ?? const <Item>[])
        if (!ids.contains(item.id)) item,
    ]);
  }

  void _replace(
    int id,
    Item Function(Item current) update,
  ) {
    final items = state.value;
    if (items == null) return;
    state = AsyncData([
      for (final item in items)
        if (item.id == id) update(item) else item,
    ]);
  }
}
