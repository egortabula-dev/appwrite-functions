/// HTTP scheme types for requests
enum HttpScheme {
  /// HTTP scheme
  http,

  /// HTTPS scheme (secure)
  https,
}

/// Extension on HttpScheme to add utility methods
extension HttpSchemeExtension on HttpScheme {
  /// Returns true if this scheme is secure (HTTPS)
  bool get isSecure => this == HttpScheme.https;

  /// Returns the string representation of the scheme
  String get value => switch (this) {
    HttpScheme.http => 'http',
    HttpScheme.https => 'https',
  };

  /// Parse a string into HttpScheme
  /// Returns HTTPS by default for security
  static HttpScheme parse(String? scheme) {
    if (scheme?.toLowerCase() == 'http') {
      return HttpScheme.http;
    }
    return HttpScheme.https; // Default to HTTPS for security
  }
}
