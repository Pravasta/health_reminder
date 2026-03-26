class UriHelper {
  static Uri createUrl({
    required String scheme,
    required String host,
    String? path,
    int? port,
    Map<String, dynamic>? queryParameters,
  }) {
    return Uri(
      scheme: scheme,
      host: host,
      path: path,
      port: port,
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
