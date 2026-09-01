import 'dart:typed_data';

import 'package:widgy_appwrite_context/src/enums/enums.dart';
import 'package:widgy_appwrite_context/src/mixins/mixins.dart';
import 'package:widgy_appwrite_context/src/models/appwrite_headers.dart';

/// {@template appwrite_request}
/// Represents the request object from Appwrite Cloud Functions context.
/// Contains all request information including headers, body, method, path, etc.
/// {@endtemplate}
class AppwriteRequest with PrettyToStringMixin {
  /// Private constructor that extracts data from dynamic context
  AppwriteRequest._(dynamic context)
    : bodyText = context?.req?.bodyText as String? ?? '',
      bodyJson = _parseBodyJson(context),
      bodyBinary = _parseBodyBinary(context),
      headers = AppwriteHeaders.fromHeaders(_parseHeaders(context)),
      scheme = HttpSchemeExtension.parse(context?.req?.scheme as String?),
      method = HttpMethodExtension.parse(context?.req?.method as String?),
      url = _parseUri(context?.req?.url as String?),
      host = context?.req?.host as String? ?? '',
      port = _parsePort(context?.req?.port),
      path = context?.req?.path as String? ?? '',
      queryString = context?.req?.queryString as String? ?? '',
      query =
          context?.req?.query as Map<String, dynamic>? ?? <String, dynamic>{};

  /// Factory method to create AppwriteRequest from dynamic context
  factory AppwriteRequest.fromContext(dynamic context) {
    return AppwriteRequest._(context);
  }

  /// Raw request body as text.
  /// Returns empty string if body is not available.
  final String bodyText;

  /// Parsed JSON body as a Map.
  /// Returns empty map if body is not valid JSON or not availableƒ.
  final Map<String, dynamic> bodyJson;

  /// Raw binary body data.
  /// Returns empty Uint8List if body is not available.
  final Uint8List bodyBinary;

  /// Type-safe Appwrite-specific headers.
  /// Provides easy access to function execution metadata like trigger,
  /// user ID, execution ID, client IP, etc.
  /// Also contains all custom (non-Appwrite) headers in `customHeaders` field.
  final AppwriteHeaders headers;

  /// HTTP scheme (protocol) of the request.
  /// Either HTTP or HTTPS. Defaults to HTTPS if not specified.
  final HttpScheme scheme;

  /// HTTP request method (GET, POST, PUT, DELETE, PATCH, etc.).
  /// Defaults to GET if not specified.
  final HttpMethod method;

  /// Full URL of the request as Uri.
  /// Example: http://awesome.appwrite.io:8000/v1/hooks?limit=12&offset=50
  /// Provides access to host, port, path, queryParameters, etc.
  final Uri url;

  /// Hostname from the host header.
  /// Example: awesome.appwrite.io
  final String host;

  /// Port from the host header.
  /// Example: 8000. Defaults to 0 if not available.
  final int port;

  /// Path part of the URL.
  /// Example: /v1/hooks
  final String path;

  /// Raw query parameters string.
  /// Example: \"limit=12&offset=50\"
  final String queryString;

  /// Parsed query parameters as a Map.
  /// Example: {"limit": "12", "offset": "50"}
  /// Access values like: req.query['limit']
  final Map<String, dynamic> query;

  /// Returns the URL as a string.
  /// Convenience getter for those who need string representation.
  String get urlString => url.toString();

  /// Helper method to parse URL string into Uri
  static Uri _parseUri(String? urlString) {
    if (urlString == null || urlString.isEmpty) {
      return Uri();
    }

    return Uri.tryParse(urlString) ?? Uri();
  }

  /// Helper method to safely parse bodyJson
  /// Catches JSON parsing errors and returns empty map
  static Map<String, dynamic> _parseBodyJson(dynamic context) {
    try {
      final bodyJson = context?.req?.bodyJson;
      if (bodyJson is Map<String, dynamic>) {
        return bodyJson;
      }
      return <String, dynamic>{};
    } catch (_) {
      // Body is empty or not valid JSON
      return <String, dynamic>{};
    }
  }

  /// Helper method to safely parse bodyBinary
  /// Converts List<int> to Uint8List if needed
  static Uint8List _parseBodyBinary(dynamic context) {
    try {
      final bodyBinary = context?.req?.bodyBinary;
      if (bodyBinary == null) return Uint8List(0);
      if (bodyBinary is Uint8List) return bodyBinary;
      if (bodyBinary is List<int>) return Uint8List.fromList(bodyBinary);
      return Uint8List(0);
    } catch (_) {
      return Uint8List(0);
    }
  }

  /// Helper method to safely parse headers
  /// Converts Map<String, dynamic> to Map<String, String>
  static Map<String, String> _parseHeaders(dynamic context) {
    try {
      final headers = context?.req?.headers;
      if (headers == null) return <String, String>{};
      if (headers is Map<String, String>) return headers;
      if (headers is Map) {
        return headers.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      }
      return <String, String>{};
    } catch (_) {
      return <String, String>{};
    }
  }

  /// Helper method to parse port value
  static int _parsePort(dynamic port) {
    if (port == null) return 0;
    if (port is int) return port;
    if (port is String) {
      return int.tryParse(port) ?? 0;
    }
    return 0;
  }

  /// Returns true if the request has a non-empty text body.
  bool get hasBodyText => bodyText.isNotEmpty;

  /// Returns true if the request has a non-empty JSON body.
  bool get hasBodyJson => bodyJson.isNotEmpty;

  /// Returns true if the request has non-empty binary body.
  bool get hasBodyBinary => bodyBinary.isNotEmpty;

  /// Returns true if the request has query parameters.
  bool get hasQuery => query.isNotEmpty;

  @override
  Map<String, dynamic> toMap() {
    return {
      'method': method.value,
      'url': urlString,
      'scheme': scheme.value,
      'host': host,
      'port': port,
      'path': path,
      'headers': headers.toMap(),
      'hasBody': hasBodyText,
      'hasQuery': hasQuery,
    };
  }
}
