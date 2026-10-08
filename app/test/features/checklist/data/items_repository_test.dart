import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mochila_peregrino/features/checklist/data/api_exception.dart';
import 'package:mochila_peregrino/features/checklist/data/items_repository.dart';
import 'package:mochila_peregrino/features/checklist/domain/item.dart';

void main() {
  const baseUrl = 'http://api.test';
  const palos = {'id': 1, 'name': 'Palos', 'packed': true, 'toBuy': false};

  ItemsRepository repositoryWith(MockClientHandler handler) {
    return ItemsRepository(client: MockClient(handler), baseUrl: baseUrl);
  }

  test('fetchItems parses the list returned by the API', () async {
    final repository = repositoryWith((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), '$baseUrl/items');
      return http.Response(jsonEncode([palos]), 200);
    });

    final items = await repository.fetchItems();

    expect(items, const [
      Item(id: 1, name: 'Palos', packed: true, toBuy: false),
    ]);
  });

  test('createItem posts the name and returns the created item', () async {
    final repository = repositoryWith((request) async {
      expect(request.method, 'POST');
      expect(jsonDecode(request.body), {'name': 'Botas'});
      return http.Response(
        jsonEncode({'id': 7, 'name': 'Botas', 'packed': false, 'toBuy': false}),
        201,
      );
    });

    final item = await repository.createItem('Botas');

    expect(item.id, 7);
    expect(item.name, 'Botas');
  });

  test('updateItem sends only the checkbox that changed', () async {
    final repository = repositoryWith((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.path, '/items/1');
      expect(jsonDecode(request.body), {'toBuy': true});
      return http.Response(jsonEncode({...palos, 'toBuy': true}), 200);
    });

    final item = await repository.updateItem(1, toBuy: true);

    expect(item.toBuy, isTrue);
    expect(item.packed, isTrue);
  });

  test('deleteItems sends every id in a single request', () async {
    var calls = 0;
    final repository = repositoryWith((request) async {
      calls++;
      expect(request.url.path, '/items/bulk-delete');
      expect(jsonDecode(request.body), {
        'ids': [1, 2, 3],
      });
      return http.Response('', 204);
    });

    await repository.deleteItems([1, 2, 3]);

    expect(calls, 1);
  });

  test('throws ApiException with the status code on HTTP errors', () async {
    final repository = repositoryWith(
      (request) async => http.Response('{"message":"Not found"}', 404),
    );

    expect(
      () => repository.updateItem(99, packed: true),
      throwsA(
        isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
      ),
    );
  });

  test('throws a network ApiException when the API is unreachable', () async {
    final repository = repositoryWith(
      (request) async => throw http.ClientException('Connection refused'),
    );

    expect(
      repository.fetchItems,
      throwsA(
        isA<ApiException>().having(
          (e) => e.isNetworkError,
          'isNetworkError',
          isTrue,
        ),
      ),
    );
  });
}
