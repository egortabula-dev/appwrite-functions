import 'dart:convert';

import 'package:appwrite_functions_context/src/appwrite_logger.dart';

/// {@template pretty_to_string_mixin}
/// Mixin that provides automatic toString() formatting based on
/// [AppwriteLogger.prettyPrint] flag.
///
/// Classes using this mixin must implement [toMap()] method that returns
/// a Map representation of the object.
///
/// The [toString()] method will automatically format the map as:
/// - Pretty JSON with indentation when [AppwriteLogger.prettyPrint] is true
/// - Compact single-line format when [AppwriteLogger.prettyPrint] is false
/// {@endtemplate}
mixin PrettyToStringMixin {
  /// Returns a Map representation of the object.
  /// This map will be automatically formatted by [toString()].
  Map<String, dynamic> toMap();

  /// Automatically returns pretty or compact string based on
  /// [AppwriteLogger.prettyPrint] flag.
  @override
  String toString() {
    final map = toMap();

    if (AppwriteLogger.prettyPrint) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(map);
      } catch (_) {
        // Fallback to default toString if JSON encoding fails
        return map.toString();
      }
    }

    return map.toString();
  }
}
