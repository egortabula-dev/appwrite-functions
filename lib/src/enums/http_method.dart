/// HTTP request methods
enum HttpMethod {
  /// GET method - retrieve data
  get,

  /// POST method - create data
  post,

  /// PUT method - update/replace data
  put,

  /// PATCH method - partially update data
  patch,

  /// DELETE method - remove data
  delete,

  /// OPTIONS method - describe communication options
  options,

  /// HEAD method - retrieve headers only
  head,
}

/// Extension on HttpMethod to add utility methods
extension HttpMethodExtension on HttpMethod {
  /// Returns the string representation of the HTTP method in uppercase
  String get value => switch (this) {
    HttpMethod.get => 'GET',
    HttpMethod.post => 'POST',
    HttpMethod.put => 'PUT',
    HttpMethod.patch => 'PATCH',
    HttpMethod.delete => 'DELETE',
    HttpMethod.options => 'OPTIONS',
    HttpMethod.head => 'HEAD',
  };

  /// Parse a string into HttpMethod
  /// Returns GET by default if method is not recognized
  static HttpMethod parse(String? method) {
    if (method == null) return HttpMethod.get;

    return switch (method.toUpperCase()) {
      'GET' => HttpMethod.get,
      'POST' => HttpMethod.post,
      'PUT' => HttpMethod.put,
      'PATCH' => HttpMethod.patch,
      'DELETE' => HttpMethod.delete,
      'OPTIONS' => HttpMethod.options,
      'HEAD' => HttpMethod.head,
      _ => HttpMethod.get, // Default to GET
    };
  }
}
