import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import 'items_repository.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(
    client: ref.watch(httpClientProvider),
    baseUrl: ApiConfig.baseUrl,
  );
});
