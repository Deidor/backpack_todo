class ApiException implements Exception {
  const ApiException({this.statusCode});

  /// HTTP status returned by the API, or null when it could not be reached.
  final int? statusCode;

  bool get isNetworkError => statusCode == null;

  @override
  String toString() => isNetworkError
      ? 'ApiException: network error'
      : 'ApiException: HTTP $statusCode';
}
