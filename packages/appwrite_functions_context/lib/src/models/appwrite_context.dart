import 'dart:async';

import 'package:appwrite_functions_context/src/appwrite_logger.dart';
import 'package:appwrite_functions_context/src/logger_zone.dart';
import 'package:appwrite_functions_context/src/models/appwrite_environment.dart';
import 'package:appwrite_functions_context/src/models/appwrite_request.dart';
import 'package:appwrite_functions_context/src/models/appwrite_response.dart';

/// {@template appwrite_functions_context}
/// Type-safe wrapper for Appwrite Cloud Functions context.
/// Provides strongly-typed access to request, response, environment, and
/// logging.
/// {@endtemplate}
class AppwriteContext {
  /// {@macro appwrite_functions_context}
  const AppwriteContext._({
    required this.req,
    required this.res,
    required this.env,
    required this.logger,
  });

  AppwriteContext._fromRaw(dynamic context, AppwriteLogger logger)
    : this._(
        req: AppwriteRequest.fromContext(context),
        res: AppwriteResponse.fromContext(context),
        env: const AppwriteEnvironment(),
        logger: logger,
      );

  /// Factory method to initialize AppwriteContext from dynamic context
  /// received in Appwrite Cloud Functions.
  ///
  /// Also makes this context the process-wide fallback for [awLog] and
  /// [awLogError]. The runtime serves concurrent requests in one process, so
  /// with that fallback a long execution's lines end up in a later one, or
  /// are lost. [handle] has no such fallback.
  @Deprecated(
    'Unsafe under concurrent requests. '
    'Use AppwriteContext.handle(context, (ctx) async { ... }) instead.',
  )
  factory AppwriteContext.initialize(dynamic context) {
    // ignore: deprecated_member_use_from_same_package
    final logger = AppwriteLogger.initialize(context);
    return AppwriteContext._fromRaw(context, logger);
  }

  /// Wraps the raw Appwrite [context] and runs [handler] with it.
  ///
  /// Log through `ctx.log` and `ctx.error`, and pass `ctx.logger` to the
  /// services that log, so every line lands in this request's execution
  /// even when the runtime serves other requests at the same time.
  ///
  /// ```dart
  /// Future<dynamic> main(dynamic context) =>
  ///     AppwriteContext.handle(context, (ctx) async {
  ///       ctx.log('Processing');
  ///       await AccountService(ctx.logger).purge();
  ///       return ctx.res.ok({'done': true});
  ///     });
  /// ```
  ///
  /// The handler runs in a zone bound to this request, so the deprecated
  /// [awLog] and [awLogError] stay safe inside it while code migrates.
  /// No global state is touched.
  static Future<T> handle<T>(
    dynamic context,
    FutureOr<T> Function(AppwriteContext ctx) handler,
  ) {
    final ctx = AppwriteContext._fromRaw(context, AppwriteLogger(context));
    return runZoned(
      () async => handler(ctx),
      zoneValues: {loggerZoneKey: ctx.logger},
    );
  }

  /// The request object containing all request information
  final AppwriteRequest req;

  /// The response builder for creating responses
  final AppwriteResponse res;

  /// Environment variables accessor for Appwrite Functions
  final AppwriteEnvironment env;

  /// Logger bound to this request's execution.
  final AppwriteLogger logger;

  /// Logs a message to this request's execution.
  ///
  /// With [data], logs [message] and then [data] as a separate line,
  /// pretty-printing Maps and Lists.
  void log(Object? message, [Object? data]) => logger.log(message, data);

  /// Logs an error to this request's execution.
  ///
  /// With [data], logs [message] and then [data] as a separate line,
  /// pretty-printing Maps and Lists.
  void error(Object? message, [Object? data]) => logger.error(message, data);
}
