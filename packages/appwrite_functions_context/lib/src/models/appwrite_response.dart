// Appwrite Cloud Functions provide a dynamic context object at runtime.
// We must call methods on this dynamic context (e.g., _context.res.json()),
// which triggers the avoid_dynamic_calls lint. Since this is required by
// the Appwrite runtime architecture, we safely ignore this warning.
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';
import 'dart:typed_data';

/// Result type returned by Appwrite Cloud Functions response methods.
///
/// This is an alias for `dynamic` as required by the Appwrite runtime,
/// but provides better semantic meaning and clearer intent in code.
/// All response methods return this type which the Appwrite runtime
/// then processes to send the HTTP response.
typedef AppwriteResponseResult = dynamic;

/// {@template appwrite_response}
/// Represents the response builder from Appwrite Cloud Functions context.
/// Provides methods to build different types of responses
/// (JSON, text, binary, redirect, empty).
///
/// See: https://appwrite.io/docs/products/functions/develop#response
/// {@endtemplate}
class AppwriteResponse {
  /// {@macro appwrite_response}
  const AppwriteResponse._(this._context);

  /// Factory method to create AppwriteResponse from dynamic context
  factory AppwriteResponse.fromContext(dynamic context) {
    return AppwriteResponse._(context);
  }

  final dynamic _context;

  /// Send an empty response with HTTP 204 status code.
  ///
  /// Returns a response with no body and a 204 No Content status.
  ///
  /// Example:
  /// ```dart
  /// return context.res.empty();
  /// ```
  ///
  /// See: https://appwrite.io/docs/products/functions/develop#empty
  AppwriteResponseResult empty() {
    return _context.res.empty();
  }

  /// Send a JSON response with the specified data.
  ///
  /// The response will have `Content-Type: application/json` header
  /// set automatically.
  ///
  /// - [data]: The data to serialize as JSON. Can be a Map, List,
  ///   or any JSON-serializable object.
  /// - [statusCode]: HTTP status code (default: 200)
  ///
  /// Example:
  /// ```dart
  /// return context.res.json({
  ///   'success': true,
  ///   'message': 'Hello from Appwrite!',
  /// });
  /// ```
  ///
  /// See: https://appwrite.io/docs/products/functions/develop#json
  AppwriteResponseResult json(
    Map<String, dynamic> data, {
    int statusCode = 200,
  }) {
    return _context.res.json(data, statusCode);
  }

  /// Send a binary response with the specified bytes.
  ///
  /// Useful for returning files, images, or other binary data.
  ///
  /// - [data]: The binary data to send as Uint8List
  /// - [statusCode]: HTTP status code (default: 200)
  /// - [headers]: Optional HTTP headers. Common headers include:
  ///   - `Content-Type`: MIME type of the binary data
  ///     (e.g., 'image/png')
  ///   - `Content-Disposition`: Filename for downloads
  ///     (e.g., 'attachment; filename="file.pdf"')
  ///
  /// Example:
  /// ```dart
  /// final bytes = Uint8List.fromList([...]);
  /// return context.res.binary(
  ///   bytes,
  ///   statusCode: 200,
  ///   headers: {
  ///     'Content-Type': 'image/png',
  ///     'Content-Disposition': 'attachment; filename="image.png"',
  ///   },
  /// );
  /// ```
  ///
  /// See: https://appwrite.io/docs/products/functions/develop#binary
  AppwriteResponseResult binary(
    Uint8List data, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return _context.res.binary(data, statusCode, headers ?? {});
  }

  /// Send a redirect response to the specified URL.
  ///
  /// - [url]: The URL to redirect to
  /// - [statusCode]: HTTP redirect status code (default: 302)
  ///   - 301: Permanent redirect
  ///   - 302: Temporary redirect (default)
  ///   - 303: See Other
  ///   - 307: Temporary redirect (preserve method)
  ///   - 308: Permanent redirect (preserve method)
  ///
  /// Example:
  /// ```dart
  /// return context.res.redirect(
  ///   'https://example.com/success',
  ///   statusCode: 302,
  /// );
  /// ```
  ///
  /// See: https://appwrite.io/docs/products/functions/develop#redirect
  AppwriteResponseResult redirect(String url, {int statusCode = 302}) {
    return _context.res.redirect(url, statusCode);
  }

  /// Send a plain text response.
  ///
  /// The response will have `Content-Type: text/plain; charset=utf-8`
  /// header set automatically.
  ///
  /// - [body]: The text content to send
  /// - [statusCode]: HTTP status code (default: 200)
  /// - [headers]: Optional additional HTTP headers
  ///
  /// Example:
  /// ```dart
  /// return context.res.text(
  ///   'Hello from Appwrite!',
  ///   statusCode: 200,
  /// );
  /// ```
  ///
  /// See: https://appwrite.io/docs/products/functions/develop#text
  AppwriteResponseResult text(
    String body, {
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return _context.res.text(body, statusCode, headers ?? {});
  }

  /// Send an HTML response.
  ///
  /// This is a convenience method that calls [text] with
  /// `Content-Type: text/html; charset=utf-8` header.
  ///
  /// - [body]: The HTML content to send
  /// - [statusCode]: HTTP status code (default: 200)
  ///
  /// Example:
  /// ```dart
  /// return context.res.html(
  ///   '<html><body><h1>Hello from Appwrite!</h1></body></html>',
  /// );
  /// ```
  AppwriteResponseResult html(String body, {int statusCode = 200}) {
    return _context.res.text(body, statusCode, {
      'Content-Type': 'text/html; charset=utf-8',
    });
  }

  // ===========================================================================
  // Success Response Helpers
  // ===========================================================================

  /// Send a successful JSON response with HTTP 200 status code.
  ///
  /// This is a convenience method for the most common success response.
  ///
  /// - [data]: The data to return in the response
  ///
  /// Example:
  /// ```dart
  /// return context.res.ok({
  ///   'user': {'id': '123', 'name': 'John'},
  /// });
  /// ```
  AppwriteResponseResult ok(Map<String, dynamic> data) {
    return json(data);
  }

  /// Send a created resource response with HTTP 201 status code.
  ///
  /// Used when a new resource has been successfully created.
  ///
  /// - [data]: The created resource data
  ///
  /// Example:
  /// ```dart
  /// return context.res.created({
  ///   'id': 'new-id-123',
  ///   'name': 'New Item',
  /// });
  /// ```
  AppwriteResponseResult created(Map<String, dynamic> data) {
    return json(data, statusCode: 201);
  }

  /// Send an accepted response with HTTP 202 status code.
  ///
  /// Used when a request has been accepted for processing,
  /// but processing is not complete. Typically used for async operations.
  ///
  /// - [data]: Optional data about the accepted request
  ///
  /// Example:
  /// ```dart
  /// return context.res.accepted({
  ///   'message': 'Request accepted for processing',
  ///   'jobId': 'job-123',
  /// });
  /// ```
  AppwriteResponseResult accepted([Map<String, dynamic>? data]) {
    return json(data ?? {'message': 'Accepted'}, statusCode: 202);
  }

  /// Send a no content response with HTTP 204 status code.
  ///
  /// Alias for [empty()]. Used when the request was successful
  /// but there's no content to return.
  ///
  /// Example:
  /// ```dart
  /// return context.res.noContent();
  /// ```
  AppwriteResponseResult noContent() {
    return empty();
  }

  // ===========================================================================
  // Error Response Helpers
  // ===========================================================================

  /// Send a bad request error response with HTTP 400 status code.
  ///
  /// Used when the request is malformed or contains invalid data.
  ///
  /// - [message]: Error message describing what's wrong
  /// - [details]: Optional additional error details or validation errors
  ///
  /// Example:
  /// ```dart
  /// return context.res.badRequest(
  ///   'Invalid request data',
  ///   details: {'email': 'Email is required'},
  /// );
  /// ```
  AppwriteResponseResult badRequest(
    String message, {
    Map<String, dynamic>? details,
  }) {
    return json({
      'error': 'Bad Request',
      'message': message,
      'details': ?details,
    }, statusCode: 400);
  }

  /// Send an unauthorized error response with HTTP 401 status code.
  ///
  /// Used when authentication is required but missing or invalid.
  ///
  /// - [message]: Error message (default: 'Authentication required')
  ///
  /// Example:
  /// ```dart
  /// return context.res.unauthorized('Invalid or expired token');
  /// ```
  AppwriteResponseResult unauthorized([
    String message = 'Authentication required',
  ]) {
    return json({'error': 'Unauthorized', 'message': message}, statusCode: 401);
  }

  /// Send a forbidden error response with HTTP 403 status code.
  ///
  /// Used when the user is authenticated but doesn't have permission
  /// to access the resource.
  ///
  /// - [message]: Error message (default: 'Access forbidden')
  ///
  /// Example:
  /// ```dart
  /// return context.res.forbidden(
  ///   'You do not have permission to delete this resource',
  /// );
  /// ```
  AppwriteResponseResult forbidden([String message = 'Access forbidden']) {
    return json({'error': 'Forbidden', 'message': message}, statusCode: 403);
  }

  /// Send a not found error response with HTTP 404 status code.
  ///
  /// Used when the requested resource doesn't exist.
  ///
  /// - [resource]: The resource that wasn't found (default: 'Resource')
  ///
  /// Example:
  /// ```dart
  /// return context.res.notFound('User');
  /// // Returns: {"error": "Not Found", "message": "User not found"}
  /// ```
  AppwriteResponseResult notFound([String resource = 'Resource']) {
    return json({
      'error': 'Not Found',
      'message': '$resource not found',
    }, statusCode: 404);
  }

  /// Send a method not allowed error response with HTTP 405 status code.
  ///
  /// Used when the HTTP method is not supported for the endpoint.
  ///
  /// - [allowed]: Optional list of allowed methods for this endpoint
  ///
  /// Example:
  /// ```dart
  /// return context.res.methodNotAllowed(['POST', 'PUT']);
  /// // Returns: {"error": "Method Not Allowed",
  /// //           "message": "This endpoint only supports: POST, PUT"}
  /// ```
  AppwriteResponseResult methodNotAllowed([List<String>? allowed]) {
    final message = allowed != null && allowed.isNotEmpty
        ? 'This endpoint only supports: ${allowed.join(', ')}'
        : 'Method not allowed';

    return json({
      'error': 'Method Not Allowed',
      'message': message,
    }, statusCode: 405);
  }

  /// Send a conflict error response with HTTP 409 status code.
  ///
  /// Used when there's a conflict with the current state of the resource.
  /// Common for duplicate entries or concurrent modifications.
  ///
  /// - [message]: Error message describing the conflict
  ///
  /// Example:
  /// ```dart
  /// return context.res.conflict(
  ///   'User with this email already exists',
  /// );
  /// ```
  AppwriteResponseResult conflict(String message) {
    return json({'error': 'Conflict', 'message': message}, statusCode: 409);
  }

  /// Send an unprocessable entity error response with
  /// HTTP 422 status code.
  ///
  /// Used when the request is well-formed but contains semantic errors.
  /// Typically used for validation errors.
  ///
  /// - [message]: Error message
  /// - [errors]: Optional map of field-specific validation errors
  ///
  /// Example:
  /// ```dart
  /// return context.res.unprocessableEntity(
  ///   'Validation failed',
  ///   errors: {
  ///     'email': 'Must be a valid email address',
  ///     'age': 'Must be at least 18',
  ///   },
  /// );
  /// ```
  AppwriteResponseResult unprocessableEntity(
    String message, {
    Map<String, dynamic>? errors,
  }) {
    return json({
      'error': 'Unprocessable Entity',
      'message': message,
      'errors': ?errors,
    }, statusCode: 422);
  }

  /// Send an internal server error response with HTTP 500 status code.
  ///
  /// Used when an unexpected error occurs on the server.
  ///
  /// - [message]: Error message (default: 'Internal server error')
  /// - [data]: Optional additional error details for debugging
  ///
  /// Example:
  /// ```dart
  /// return context.res.internalError(
  ///   'Database connection failed',
  ///   data: {'query': 'SELECT * FROM users', 'error': e.toString()},
  /// );
  /// ```
  AppwriteResponseResult internalError({
    String message = 'Internal server error',
    Map<String, dynamic>? data,
  }) {
    return json({
      'error': 'Internal Server Error',
      'message': message,
      'data': ?data,
    }, statusCode: 500);
  }

  /// Send a too many requests error response with HTTP 429 status code.
  ///
  /// Used when rate limiting is applied to prevent abuse.
  ///
  /// - [message]: Error message (default: 'Too many requests')
  /// - [retryAfter]: Optional retry after value in seconds
  ///   (included in response body)
  ///
  /// Example:
  /// ```dart
  /// return context.res.tooManyRequests(
  ///   'Rate limit exceeded',
  ///   retryAfter: 60,
  /// );
  /// ```
  AppwriteResponseResult tooManyRequests({
    String message = 'Too many requests',
    int? retryAfter,
  }) {
    return json({
      'error': 'Too Many Requests',
      'message': message,
      'retryAfter': ?retryAfter,
    }, statusCode: 429);
  }

  /// Send a service unavailable error response with HTTP 503 status code.
  ///
  /// Used when the service is temporarily unavailable
  /// (maintenance, overload, etc.).
  ///
  /// - [message]: Error message
  ///   (default: 'Service temporarily unavailable')
  /// - [retryAfter]: Optional retry after value in seconds
  ///   (included in response body)
  ///
  /// Example:
  /// ```dart
  /// return context.res.serviceUnavailable(
  ///   'System maintenance in progress',
  ///   retryAfter: 3600,
  /// );
  /// ```
  AppwriteResponseResult serviceUnavailable({
    String message = 'Service temporarily unavailable',
    int? retryAfter,
  }) {
    return json({
      'error': 'Service Unavailable',
      'message': message,
      'retryAfter': ?retryAfter,
    }, statusCode: 503);
  }

  /// Send a validation error response with field-specific errors.
  ///
  /// Improved version of [unprocessableEntity] for handling
  /// multiple errors per field.
  ///
  /// - [fieldErrors]: Map of field names to lists of error messages
  /// - [message]: Optional overall error message
  ///   (default: 'Validation failed')
  ///
  /// Example:
  /// ```dart
  /// return context.res.validationError({
  ///   'email': ['Email is required', 'Email must be valid'],
  ///   'password': ['Password must be at least 8 characters'],
  /// });
  /// ```
  AppwriteResponseResult validationError(
    Map<String, List<String>> fieldErrors, {
    String message = 'Validation failed',
  }) {
    return json({
      'error': 'Validation Error',
      'message': message,
      'errors': fieldErrors,
    }, statusCode: 422);
  }

  /// Send a success response with a standard format.
  ///
  /// Creates a consistent success response structure
  /// with optional data.
  ///
  /// - [message]: Success message
  /// - [data]: Optional additional data to include
  /// - [statusCode]: HTTP status code (default: 200)
  ///
  /// Example:
  /// ```dart
  /// return context.res.success(
  ///   'User created successfully',
  ///   data: {'userId': '123', 'email': 'user@example.com'},
  /// );
  /// ```
  AppwriteResponseResult success(
    String message, {
    Map<String, dynamic>? data,
    int statusCode = 200,
  }) {
    return json({
      'success': true,
      'message': message,
      'data': ?data,
    }, statusCode: statusCode);
  }

  // ===========================================================================
  // Additional Helpers
  // ===========================================================================

  /// Send a custom response with full control over the body and headers.
  ///
  /// This is a low-level method that gives you complete control
  /// over the response.
  ///
  /// - [body]: The response body (can be String, Map, List, etc.)
  /// - [statusCode]: HTTP status code (default: 200)
  /// - [headers]: Optional HTTP headers
  ///
  /// Example:
  /// ```dart
  /// return context.res.send(
  ///   body: 'Custom response',
  ///   statusCode: 418,
  ///   headers: {'X-Custom-Header': 'value'},
  /// );
  /// ```
  AppwriteResponseResult send({
    required String body,
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return text(body, statusCode: statusCode, headers: headers);
  }

  /// Send a file for download with appropriate headers.
  ///
  /// Automatically sets the Content-Disposition header
  /// for file downloads.
  ///
  /// - [data]: The binary file data
  /// - [filename]: The name of the file to download
  /// - [mimeType]: Optional MIME type
  ///   (default: 'application/octet-stream')
  ///
  /// Example:
  /// ```dart
  /// final pdfData = Uint8List.fromList([...]);
  /// return context.res.downloadFile(
  ///   pdfData,
  ///   'report.pdf',
  ///   mimeType: 'application/pdf',
  /// );
  /// ```
  AppwriteResponseResult downloadFile(
    Uint8List data,
    String filename, {
    String? mimeType,
  }) {
    return binary(
      data,
      headers: {
        'Content-Type': mimeType ?? 'application/octet-stream',
        'Content-Disposition': 'attachment; filename="$filename"',
      },
    );
  }

  /// Send a JSON file for download.
  ///
  /// Convenience method to download JSON data as a file.
  ///
  /// - [data]: The data to serialize as JSON
  /// - [filename]: The name of the JSON file
  ///
  /// Example:
  /// ```dart
  /// return context.res.downloadJSON(
  ///   {'users': [...]},
  ///   'users-export.json',
  /// );
  /// ```
  AppwriteResponseResult downloadJSON(
    Map<String, dynamic> data,
    String filename,
  ) {
    final jsonString = _encodeJson(data);
    return binary(
      Uint8List.fromList(jsonString.codeUnits),
      headers: {
        'Content-Type': 'application/json',
        'Content-Disposition': 'attachment; filename="$filename"',
      },
    );
  }

  /// Helper method to encode JSON with proper formatting
  String _encodeJson(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } on Exception {
      return '{}';
    }
  }
}
