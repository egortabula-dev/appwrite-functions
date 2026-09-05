/// Converts a message to a string representation.
///
/// If the message is already a [String], returns it as-is.
/// Otherwise, calls [toString()] on the message.
/// Returns empty string if message is null.
String messageToString(Object? message) {
  if (message == null) return '';
  return message is String ? message : message.toString();
}
