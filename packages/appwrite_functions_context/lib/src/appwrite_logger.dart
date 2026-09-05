// We use dynamic calls to interact with the Appwrite context object
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:appwrite_functions_context/src/models/models.dart'
    show AppwriteContext;
import 'package:appwrite_functions_context/src/models/appwrite_context.dart'
    show AppwriteContext;
import 'package:appwrite_functions_context/appwrite_functions_context.dart'
    show AppwriteContext;

/// {@template appwrite_logger}
/// Logger for Appwrite Cloud Functions.
/// Provides methods for logging messages and errors
/// to the Appwrite Console.
/// {@endtemplate}
class AppwriteLogger {
  /// Initialize the logger with the Appwrite context.
  /// This is called automatically by [AppwriteContext.initialize].
  factory AppwriteLogger.initialize(dynamic context) {
    _instance = AppwriteLogger._(context);
    return _instance!;
  }
  AppwriteLogger._(this._context);

  static AppwriteLogger? _instance;

  final dynamic _context;

  /// Enable or disable pretty printing for Maps and Lists in logs.
  /// When enabled, complex objects are formatted with indentation.
  /// Default is true.
  static bool prettyPrint = true;

  /// Logs a message to Appwrite Console.
  /// Messages logged here are visible in the Appwrite Console
  /// but not to end users.
  void log(Object? message) {
    _context?.log(_formatMessage(message));
  }

  /// Logs an error to Appwrite Console.
  /// Errors logged here are visible in the Appwrite Console
  /// but not to end users.
  void error(Object? message) {
    _context?.error(_formatMessage(message));
  }

  /// Formats message for logging, applying pretty print if enabled
  static String _formatMessage(Object? message) {
    if (message == null) return '';
    if (message is String) return message;

    // If pretty print is enabled, format Maps and Lists nicely
    if (prettyPrint) {
      try {
        // Try to encode as JSON with indentation
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(message);
      } catch (_) {
        // If JSON encoding fails, fall back to toString
        return message.toString();
      }
    }

    return message.toString();
  }
}

/// Top-level convenience function for logging messages.
///
/// Can be used in two modes:
/// - Single argument: `awLog(message)` - logs the message as-is
/// - Two arguments: `awLog('label:', data)` - logs label and data separately
///   with automatic pretty-printing for Maps/Lists
///
/// Examples:
/// ```dart
/// awLog('Simple message');
/// awLog('Query:', ctx.req.query);  // Auto pretty-print
/// awLog(ctx.req.query);            // Also pretty-printed
/// ```
void awLog(Object? message, [Object? data]) {
  if (data != null) {
    // Two arguments mode: log label and data separately
    AppwriteLogger._instance?.log(message);
    AppwriteLogger._instance?.log(data);
  } else {
    // Single argument mode: log as-is
    AppwriteLogger._instance?.log(message);
  }
}

/// Top-level convenience function for logging errors.
///
/// Can be used in two modes:
/// - Single argument: `awLogError(message)` - logs the error as-is
/// - Two arguments: `awLogError('label:', error)` - logs label and error
///   separately with automatic pretty-printing for Maps/Lists
///
/// Examples:
/// ```dart
/// awLogError('Error occurred');
/// awLogError('Request failed:', ctx.req.query);
/// awLogError(exception);
/// ```
void awLogError(Object? message, [Object? data]) {
  if (data != null) {
    // Two arguments mode: log label and data separately
    AppwriteLogger._instance?.error(message);
    AppwriteLogger._instance?.error(data);
  } else {
    // Single argument mode: log as-is
    AppwriteLogger._instance?.error(message);
  }
}
