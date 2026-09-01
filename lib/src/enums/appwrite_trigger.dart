/// {@template appwrite_trigger}
/// Describes how the Appwrite function execution was invoked.
/// {@endtemplate}
enum AppwriteTrigger {
  /// Function was triggered by an HTTP request
  http,

  /// Function was triggered by a scheduled execution
  schedule,

  /// Function was triggered by an Appwrite event
  event,
}

/// Extension on [AppwriteTrigger] to provide additional functionality.
extension AppwriteTriggerExtension on AppwriteTrigger {
  /// Returns the uppercase string value of the trigger.
  /// Example: AppwriteTrigger.http.value => 'HTTP'
  String get value => name.toUpperCase();

  /// Parses a string value into an [AppwriteTrigger].
  /// Returns [AppwriteTrigger.http] if the value is null or invalid.
  static AppwriteTrigger parse(String? value) {
    if (value == null) return AppwriteTrigger.http;

    switch (value.toLowerCase()) {
      case 'http':
        return AppwriteTrigger.http;
      case 'schedule':
        return AppwriteTrigger.schedule;
      case 'event':
        return AppwriteTrigger.event;
      default:
        return AppwriteTrigger.http;
    }
  }
}
