import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/feature_flags.dart';
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

class ChecklistController extends AsyncNotifier<List<Item>> {
  ItemsRepository get _repository => ref.read(itemsRepositoryProvider);

  @override
  Future<List<Item>> build() {
    return ref.watch(itemsRepositoryProvider).fetchItems();
  }

  void reload() => ref.invalidateSelf();

  Future<void> setPacked(Item item, bool value) {
    return _update(item, packed: value, toBuy: _clearsOther(value));
  }

  Future<void> setToBuy(Item item, bool value) {
    return _update(item, toBuy: value, packed: _clearsOther(value));
  }

  /// In exclusive mode, ticking one checkbox unticks the other one.
  bool? _clearsOther(bool value) {
    return value && ref.read(exclusiveCheckboxesProvider) ? false : null;
  }

  Future<void> _update(Item item, {bool? packed, bool? toBuy}) async {
    _replace(
      item.id,
      (current) => current.copyWith(packed: packed, toBuy: toBuy),
    );
    try {
      await _repository.updateItem(item.id, packed: packed, toBuy: toBuy);
    } on ApiException {
      // Restores only the fields this change touched.
      _replace(
        item.id,
        (current) => current.copyWith(
          packed: packed == null ? null : item.packed,
          toBuy: toBuy == null ? null : item.toBuy,
        ),
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

  void _replace(int id, Item Function(Item current) update) {
    final items = state.value;
    if (items == null) return;
    state = AsyncData([
      for (final item in items)
        if (item.id == id) update(item) else item,
    ]);
  }
}
