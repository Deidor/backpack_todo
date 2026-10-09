import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/items_providers.dart';
import '../domain/item.dart';

final checklistControllerProvider =
    AsyncNotifierProvider<ChecklistController, List<Item>>(
      ChecklistController.new,
      // The error state offers a manual retry instead.
      retry: (retryCount, error) => null,
    );

class ChecklistController extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() {
    return ref.watch(itemsRepositoryProvider).fetchItems();
  }

  void reload() => ref.invalidateSelf();
}
