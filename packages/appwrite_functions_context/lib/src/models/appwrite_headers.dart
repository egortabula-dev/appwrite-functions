import 'package:appwrite_functions_context/src/enums/enums.dart';
import 'package:appwrite_functions_context/src/mixins/mixins.dart';

/// {@template appwrite_headers}
/// Type-safe wrapper for Appwrite-specific headers.
/// Provides easy access to function execution metadata.
///
/// See: https://appwrite.io/docs/products/functions/develop#headers
/// {@endtemplate}
class AppwriteHeaders with PrettyToStringMixin {
  /// Private constructor that extracts Appwrite headers from the headers map
  AppwriteHeaders._(Map<String, String> headers)
    : trigger = AppwriteTriggerExtension.parse(headers['x-appwrite-trigger']),
      event = headers['x-appwrite-event']?.isEmpty ?? true
          ? null
          : headers['x-appwrite-event'],
      apiKey = headers['x-appwrite-key'] ?? '',
      userId = headers['x-appwrite-user-id']?.isEmpty ?? true
          ? null
          : headers['x-appwrite-user-id'],
      userJwt = headers['x-appwrite-user-jwt']?.isEmpty ?? true
          ? null
          : headers['x-appwrite-user-jwt'],
      countryCode = headers['x-appwrite-country-code']?.isEmpty ?? true
          ? null
          : headers['x-appwrite-country-code'],
      continentCode = headers['x-appwrite-continent-code']?.isEmpty ?? true
          ? null
          : headers['x-appwrite-continent-code'],
      isInEU = headers['x-appwrite-continent-eu'] == 'true',
      clientIp = headers['x-appwrite-client-ip'] ?? '',
      executionId = headers['x-appwrite-execution-id'] ?? '',
      authorization = headers['authorization']?.isEmpty ?? true
          ? null
          : headers['authorization'],
      contentType = headers['content-type']?.isEmpty ?? true
          ? null
          : headers['content-type'],
      contentLength = int.tryParse(headers['content-length'] ?? '') ?? 0,
      accept = headers['accept']?.isEmpty ?? true ? null : headers['accept'],
      host = headers['host']?.isEmpty ?? true ? null : headers['host'],
      cookie = headers['cookie']?.isEmpty ?? true ? null : headers['cookie'],
      cacheControl = headers['cache-control']?.isEmpty ?? true
          ? null
          : headers['cache-control'],
      forwarded = headers['forwarded']?.isEmpty ?? true
          ? null
          : headers['forwarded'],
      userAgent = headers['user-agent']?.isEmpty ?? true
          ? null
          : headers['user-agent'],
      referer = headers['referer']?.isEmpty ?? true ? null : headers['referer'],
      origin = headers['origin']?.isEmpty ?? true ? null : headers['origin'],
      customHeaders = _extractCustomHeaders(headers);

  /// Factory method to create AppwriteHeaders from headers map
  factory AppwriteHeaders.fromHeaders(Map<String, String> headers) {
    return AppwriteHeaders._(headers);
  }

  /// Appwrite-specific header keys
  static const _appwriteHeaderKeys = {
    'x-appwrite-trigger',
    'x-appwrite-event',
    'x-appwrite-key',
    'x-appwrite-user-id',
    'x-appwrite-user-jwt',
    'x-appwrite-country-code',
    'x-appwrite-continent-code',
    'x-appwrite-continent-eu',
    'x-appwrite-client-ip',
    'x-appwrite-execution-id',
  };

  /// Standard HTTP header keys that are extracted as separate fields
  static const _standardHeaderKeys = {
    'authorization',
    'content-type',
    'content-length',
    'accept',
    'host',
    'cookie',
    'cache-control',
    'forwarded',
    'user-agent',
    'referer',
    'origin',
  };

  /// Extracts all non-Appwrite headers (custom headers)
  static Map<String, String> _extractCustomHeaders(
    Map<String, String> headers,
  ) {
    return Map.fromEntries(
      headers.entries.where(
        (entry) =>
            !_appwriteHeaderKeys.contains(entry.key.toLowerCase()) &&
            !_standardHeaderKeys.contains(entry.key.toLowerCase()),
      ),
    );
  }

  /// Header: `x-appwrite-trigger`
  ///
  /// Describes how the function execution was invoked.
  /// Possible values: http, schedule, or event.
  /// Always present.
  final AppwriteTrigger trigger;

  /// Header: `x-appwrite-event`
  ///
  /// If the function execution was triggered by an event,
  /// describes the triggering event.
  /// Null when not triggered by event.
  /// Always present but may be empty.
  final String? event;

  /// Header: `x-appwrite-key`
  ///
  /// The dynamic API key used for server authentication.
  /// Always present.
  final String apiKey;

  /// Header: `x-appwrite-user-id`
  ///
  /// If the function execution was invoked by an authenticated user,
  /// displays the user ID.
  /// Null when not authenticated or invoked by Console/API keys.
  /// Always present but may be empty.
  final String? userId;

  /// Header: `x-appwrite-user-jwt`
  ///
  /// JWT token generated from the invoking user's session.
  /// Used to authenticate Server SDKs to respect access permissions.
  /// Null when no user session.
  /// Always present but may be empty.
  final String? userJwt;

  /// Header: `x-appwrite-country-code`
  ///
  /// Country code of the configured locale.
  /// Null if not available.
  /// Always present but may be empty.
  final String? countryCode;

  /// Header: `x-appwrite-continent-code`
  ///
  /// Continent code of the configured locale.
  /// Null if not available.
  /// Always present but may be empty.
  final String? continentCode;

  /// Header: `x-appwrite-continent-eu`
  ///
  /// Describes if the configured locale is within the EU.
  /// Always present.
  final bool isInEU;

  /// Header: `x-appwrite-client-ip`
  ///
  /// IP address of the client creating the execution.
  /// Always present.
  final String clientIp;

  /// Header: `x-appwrite-execution-id`
  ///
  /// ID of the current execution.
  /// Always present.
  final String executionId;

  /// Header: `authorization`
  ///
  /// Authorization header sent with the request.
  /// Null if not present.
  final String? authorization;

  /// Header: `content-type`
  ///
  /// Content type of the request body.
  /// Null if not present.
  final String? contentType;

  /// Header: `content-length`
  ///
  /// Length of the request body in bytes.
  /// 0 if not present or invalid.
  final int contentLength;

  /// Header: `accept`
  ///
  /// Accept header sent with the request.
  /// Null if not present.
  final String? accept;

  /// Header: `host`
  ///
  /// Host header sent with the request.
  /// Null if not present.
  final String? host;

  /// Header: `cookie`
  ///
  /// Cookie header sent with the request.
  /// Null if not present.
  final String? cookie;

  /// Header: `cache-control`
  ///
  /// Cache-Control header sent with the request.
  /// Null if not present.
  final String? cacheControl;

  /// Header: `forwarded`
  ///
  /// Forwarded header sent with the request.
  /// Null if not present.
  final String? forwarded;

  /// Header: `user-agent`
  ///
  /// User-Agent header sent with the request.
  /// Null if not present.
  final String? userAgent;

  /// Header: `referer`
  ///
  /// Referer header sent with the request.
  /// Null if not present.
  final String? referer;

  /// Header: `origin`
  ///
  /// Origin header sent with the request.
  /// Null if not present.
  final String? origin;

  /// All custom (non-Appwrite and non-standard) headers sent with the request.
  /// These are any headers that are not Appwrite-specific or standard HTTP
  /// headers.
  final Map<String, String> customHeaders;

  /// Returns true if the function was triggered by an HTTP request.
  bool get isHttpTrigger => trigger == AppwriteTrigger.http;

  /// Returns true if the function was triggered by a schedule.
  bool get isScheduleTrigger => trigger == AppwriteTrigger.schedule;

  /// Returns true if the function was triggered by an event.
  bool get isEventTrigger => trigger == AppwriteTrigger.event;

  /// Returns true if the execution has an authenticated user.
  bool get hasUser => userId != null;

  /// Returns true if the execution has a user JWT token.
  bool get hasUserJwt => userJwt != null;

  /// Returns true if the execution was triggered by an event.
  bool get hasEvent => event != null;

  /// Returns true if there are custom (non-Appwrite and non-standard) headers.
  bool get hasCustomHeaders => customHeaders.isNotEmpty;

  /// Returns true if authorization header is present.
  bool get hasAuthorization => authorization != null;

  /// Returns true if content-type header is present.
  bool get hasContentType => contentType != null;

  /// Convenient getter for [toMap()].
  /// Returns the headers as a Map with all fields.
  Map<String, dynamic> get asMap => toMap();

  /// Returns the headers as a Map excluding null values.
  /// Only includes fields that have actual values.
  Map<String, dynamic> get asMapNonNull {
    final map = toMap()..removeWhere((key, value) => value == null);
    return map;
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'trigger': trigger.value,
      'executionId': executionId,
      'userId': userId,
      'event': event,
      'clientIp': clientIp,
      'countryCode': countryCode,
      'continentCode': continentCode,
      'isInEU': isInEU,
      'authorization': authorization,
      'contentType': contentType,
      'contentLength': contentLength,
      'accept': accept,
      'host': host,
      'cookie': cookie,
      'cacheControl': cacheControl,
      'forwarded': forwarded,
      'userAgent': userAgent,
      'referer': referer,
      'origin': origin,
      if (hasCustomHeaders) 'customHeaders': customHeaders,
    };
  }
}
