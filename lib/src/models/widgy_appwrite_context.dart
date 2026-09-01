import 'package:widgy_appwrite_context/src/appwrite_logger.dart';
import 'package:widgy_appwrite_context/src/models/appwrite_environment.dart';
import 'package:widgy_appwrite_context/src/models/appwrite_request.dart';
import 'package:widgy_appwrite_context/src/models/appwrite_response.dart';

/// {@template widgy_appwrite_context}
/// Type-safe wrapper for Appwrite Cloud Functions context.
/// Provides strongly-typed access to request, response, environment, and
/// logging.
/// {@endtemplate}
class AppwriteContext {
  /// {@macro widgy_appwrite_context}
  const AppwriteContext._({
    required this.req,
    required this.res,
    required this.env,
  });

  /// Factory method to initialize AppwriteContext from dynamic context
  /// received in Appwrite Cloud Functions.
  factory AppwriteContext.initialize(dynamic context) {
    // Initialize logger with context
    AppwriteLogger.initialize(context);

    return AppwriteContext._(
      req: AppwriteRequest.fromContext(context),
      res: AppwriteResponse.fromContext(context),
      env: const AppwriteEnvironment(),
    );
  }

  /// The request object containing all request information
  final AppwriteRequest req;

  /// The response builder for creating responses
  final AppwriteResponse res;

  /// Environment variables accessor for Appwrite Functions
  final AppwriteEnvironment env;
}
