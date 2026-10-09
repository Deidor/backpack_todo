import 'package:mochila_peregrino/features/checklist/data/api_exception.dart';
import 'package:mochila_peregrino/features/checklist/data/items_repository.dart';
import 'package:mochila_peregrino/features/checklist/domain/item.dart';

/// In-memory stand-in for the HTTP repository.
class FakeItemsRepository implements ItemsRepository {
  FakeItemsRepository({List<Item> items = const [], this.onFetch})
    : items = [...items];

  final List<Item> items;
  final Future<List<Item>> Function()? onFetch;

  /// When true, every write fails as if the API were unreachable.
  bool failWrites = false;

  @override
  Future<List<Item>> fetchItems() async {
    final onFetch = this.onFetch;
    if (onFetch != null) return onFetch();
    return [...items];
  }

  @override
  Future<Item> createItem(String name) async {
    _checkWrite();
    final item = Item(
      id: items.length + 100,
      name: name,
      packed: false,
      toBuy: false,
    );
    items.add(item);
    return item;
  }

  @override
  Future<Item> updateItem(int id, {bool? packed, bool? toBuy}) async {
    _checkWrite();
    final index = items.indexWhere((item) => item.id == id);
    final updated = items[index].copyWith(packed: packed, toBuy: toBuy);
    items[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteItems(List<int> ids) async {
    _checkWrite();
    items.removeWhere((item) => ids.contains(item.id));
  }

  void _checkWrite() {
    if (failWrites) throw const ApiException();
  }
}
