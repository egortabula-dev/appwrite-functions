import 'dart:io';

/// Provides type-safe access to Appwrite Cloud Functions
/// environment variables.
///
/// These variables are automatically set by the Appwrite runtime
/// and contain information about the running function, project,
/// and execution context.
///
/// Example:
/// ```dart
/// final env = AppwriteEnvironment();
///
/// print('Function ID: ${env.functionId}');
/// print('Project ID: ${env.projectId}');
/// print('Region: ${env.region}');
/// ```
///
/// For testing, you can provide custom environment variables:
/// ```dart
/// final testEnv = AppwriteEnvironment(environment: {
///   'APPWRITE_FUNCTION_ID': 'test-function-id',
///   'APPWRITE_FUNCTION_PROJECT_ID': 'test-project-id',
/// });
/// ```
class AppwriteEnvironment {
  /// Creates an instance of AppwriteEnvironment.
  ///
  /// If [environment] is provided, it will be used instead of
  /// [Platform.environment]. This is useful for testing.
  const AppwriteEnvironment({Map<String, String>? environment})
    : _environment = environment;

  final Map<String, String>? _environment;

  /// Returns the environment Map to use (custom or Platform.environment).
  Map<String, String> get _env => _environment ?? Platform.environment;

  /// The API endpoint of the running function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `https://cloud.appwrite.io/v1`
  String get apiEndpoint => _env['APPWRITE_FUNCTION_API_ENDPOINT'] ?? '';

  /// The Appwrite version used to run the function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `1.4.0`
  String get appwriteVersion => _env['APPWRITE_VERSION'] ?? '';

  /// The region where the function will run from.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `default`
  String get region => _env['APPWRITE_REGION'] ?? '';

  /// The function API key used for server authentication.
  ///
  /// Available at: Build time only
  ///
  /// **Warning**: This key should be kept secure and never exposed
  /// in client-side code or logs.
  String? get apiKey => _env['APPWRITE_FUNCTION_API_KEY'];

  /// The ID of the running function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `64a1b2c3d4e5f6g7h8i9j0k1`
  String get functionId => _env['APPWRITE_FUNCTION_ID'] ?? '';

  /// The name of the running function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `my-awesome-function`
  String get functionName => _env['APPWRITE_FUNCTION_NAME'] ?? '';

  /// The deployment ID of the running function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `64a1b2c3d4e5f6g7h8i9j0k2`
  String get deployment => _env['APPWRITE_FUNCTION_DEPLOYMENT'] ?? '';

  /// The project ID of the running function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `64a1b2c3d4e5f6g7h8i9j0k3`
  String get projectId => _env['APPWRITE_FUNCTION_PROJECT_ID'] ?? '';

  /// The runtime of the running function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `dart-3.0`
  String get runtimeName => _env['APPWRITE_FUNCTION_RUNTIME_NAME'] ?? '';

  /// The runtime version of the running function.
  ///
  /// Available at: Build time and Run time
  ///
  /// Example: `3.0.0`
  String get runtimeVersion => _env['APPWRITE_FUNCTION_RUNTIME_VERSION'] ?? '';

  /// Convenient getter for [toMap()].
  /// Returns the headers as a Map with all fields.
  Map<String, String?> get asMap => toMap();

  /// Returns the headers as a Map excluding null values.
  /// Only includes fields that have actual values.
  Map<String, String> get asMapNonNull {
    return Map<String, String>.fromEntries(
      toMap().entries
          .where((e) => e.value != null)
          .map(
            (e) => MapEntry(e.key, e.value!),
          ),
    );
  }

  /// Returns all Appwrite environment variables as a Map.
  ///
  /// This includes all variables starting with `APPWRITE_`.
  /// Useful for debugging or logging purposes.
  Map<String, String?> toMap() {
    return {
      'apiEndpoint': apiEndpoint,
      'appwriteVersion': appwriteVersion,
      'region': region,
      if (apiKey != null) 'apiKey': '***', // Masked for security
      'functionId': functionId,
      'functionName': functionName,
      'deployment': deployment,
      'projectId': projectId,
      'runtimeName': runtimeName,
      'runtimeVersion': runtimeVersion,
    };
  }

  @override
  String toString() {
    return 'AppwriteEnvironment${toMap()}';
  }
}
