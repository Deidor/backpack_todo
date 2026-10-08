import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mochila_peregrino/features/checklist/domain/item.dart';

import 'api_exception.dart';

class ItemsRepository {
  ItemsRepository({required this._client, required this._baseUrl});

  static const Duration _timeout = Duration(seconds: 10);
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  final http.Client _client;
  final String _baseUrl;

  Future<List<Item>> fetchItems() async {
    final response = await _send(() => _client.get(_uri('/items')));
    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((json) => Item.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Item> createItem(String name) async {
    final response = await _send(
      () => _client.post(
        _uri('/items'),
        headers: _jsonHeaders,
        body: jsonEncode({'name': name}),
      ),
    );
    return Item.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Item> updateItem(int id, {bool? packed, bool? toBuy}) async {
    final response = await _send(
      () => _client.patch(
        _uri('/items/$id'),
        headers: _jsonHeaders,
        body: jsonEncode({'packed': ?packed, 'toBuy': ?toBuy}),
      ),
    );
    return Item.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteItems(List<int> ids) async {
    await _send(
      () => _client.post(
        _uri('/items/bulk-delete'),
        headers: _jsonHeaders,
        body: jsonEncode({'ids': ids}),
      ),
    );
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ApiException();
    } on http.ClientException {
      throw const ApiException();
    }
    if (response.statusCode >= 400) {
      throw ApiException(statusCode: response.statusCode);
    }
    return response;
  }
}
