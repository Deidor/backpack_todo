import 'package:flutter/foundation.dart';

@immutable
class Item {
  const Item({
    required this.id,
    required this.name,
    required this.packed,
    required this.toBuy,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as int,
      name: json['name'] as String,
      packed: json['packed'] as bool,
      toBuy: json['toBuy'] as bool,
    );
  }

  final int id;
  final String name;
  final bool packed;
  final bool toBuy;

  Item copyWith({bool? packed, bool? toBuy}) {
    return Item(
      id: id,
      name: name,
      packed: packed ?? this.packed,
      toBuy: toBuy ?? this.toBuy,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is Item &&
        other.id == id &&
        other.name == name &&
        other.packed == packed &&
        other.toBuy == toBuy;
  }

  @override
  int get hashCode => Object.hash(id, name, packed, toBuy);
}
