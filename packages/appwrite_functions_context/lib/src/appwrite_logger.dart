// We use dynamic calls to interact with the Appwrite context object
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:appwrite_functions_context/src/logger_zone.dart';
import 'package:appwrite_functions_context/src/models/appwrite_context.dart'
    show AppwriteContext;

/// {@template appwrite_logger}
/// Logger for Appwrite Cloud Functions.
/// Provides methods for logging messages and errors
/// to the Appwrite Console.
/// {@endtemplate}
class AppwriteLogger {
  /// Creates a logger bound to one raw Appwrite [context].
  ///
  /// The logger writes only to that context and touches no global state, so
  /// it is safe when the runtime serves several requests at once.
  AppwriteLogger(this._context);

  /// Initialize the logger with the Appwrite context and make it the
  /// process-wide fallback used by [awLog] and [awLogError] outside of
  /// [AppwriteContext.handle].
  ///
  /// The open-runtimes Dart server runs concurrent requests in one isolate,
  /// and every call replaces the fallback. A request that is still running
  /// when another one starts will send its later [awLog] lines to the other
  /// request, or lose them if that request has already finished.
  @Deprecated(
    'Unsafe under concurrent requests. '
    'Use AppwriteContext.handle, or AppwriteLogger(context) for a logger '
    'bound to one context.',
  )
  factory AppwriteLogger.initialize(dynamic context) {
    return _instance = AppwriteLogger(context);
  }

  static AppwriteLogger? _instance;

  final dynamic _context;

  /// Enable or disable pretty printing for Maps and Lists in logs.
  /// When enabled, complex objects are formatted with indentation.
  /// Default is true.
  static bool prettyPrint = true;

  /// Logs a message to Appwrite Console.
  /// Messages logged here are visible in the Appwrite Console
  /// but not to end users.
  ///
  /// With [data], logs [message] and then [data] as a separate line,
  /// pretty-printing Maps and Lists.
  void log(Object? message, [Object? data]) {
    _context?.log(_formatMessage(message));
    if (data != null) _context?.log(_formatMessage(data));
  }

  /// Logs an error to Appwrite Console.
  /// Errors logged here are visible in the Appwrite Console
  /// but not to end users.
  ///
  /// With [data], logs [message] and then [data] as a separate line,
  /// pretty-printing Maps and Lists.
  void error(Object? message, [Object? data]) {
    _context?.error(_formatMessage(message));
    if (data != null) _context?.error(_formatMessage(data));
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

AppwriteLogger? get _currentLogger => zoneLogger ?? AppwriteLogger._instance;

/// Top-level convenience function for logging messages.
///
/// Can be used in two modes:
/// - Single argument: `awLog(message)` - logs the message as-is
/// - Two arguments: `awLog('label:', data)` - logs label and data separately
///   with automatic pretty-printing for Maps/Lists
///
/// Inside [AppwriteContext.handle] it writes to that request's execution.
/// Outside of it, it falls back to the context most recently passed to the
/// deprecated `AppwriteContext.initialize`, which is not safe when the
/// runtime serves concurrent requests, and does nothing without one.
///
/// Replace with [AppwriteContext.log], and hand `ctx.logger` to services
/// that log.
@Deprecated('Use ctx.log, and pass ctx.logger to services that need to log.')
void awLog(Object? message, [Object? data]) {
  _currentLogger?.log(message, data);
}

/// Top-level convenience function for logging errors.
///
/// Can be used in two modes:
/// - Single argument: `awLogError(message)` - logs the error as-is
/// - Two arguments: `awLogError('label:', error)` - logs label and error
///   separately with automatic pretty-printing for Maps/Lists
///
/// Picks the target execution the same way as [awLog]: the request of the
/// enclosing [AppwriteContext.handle] if there is one, otherwise the
/// deprecated global fallback.
///
/// Replace with [AppwriteContext.error], and hand `ctx.logger` to services
/// that log.
@Deprecated('Use ctx.error, and pass ctx.logger to services that need to log.')
void awLogError(Object? message, [Object? data]) {
  _currentLogger?.error(message, data);
}
