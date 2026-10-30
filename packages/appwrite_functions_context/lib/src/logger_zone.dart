import 'dart:async';

import 'package:appwrite_functions_context/src/appwrite_logger.dart';

/// Zone value key under which `AppwriteContext.handle` stores the logger of
/// the request it runs. Private to the package so user code cannot clobber it.
final Object loggerZoneKey = Object();

/// The logger bound to the current zone, if any.
AppwriteLogger? get zoneLogger {
  final logger = Zone.current[loggerZoneKey];
  return logger is AppwriteLogger ? logger : null;
}
