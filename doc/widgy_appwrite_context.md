# widgy_appwrite_context — Package Documentation for MCP Server

## Package Identity

- **Name**: `widgy_appwrite_context`
- **Version**: `0.2.6`
- **Language**: Dart
- **SDK constraint**: `>=3.0.0 <4.0.0`
- **License**: MIT
- **Pub server**: `https://pub.widgy.io` (private)
- **Purpose**: Type-safe wrapper for Appwrite Cloud Functions dynamic `context` object. Replaces raw dynamic access with strongly-typed classes for request, response, headers, environment variables, and logging.

## When to Use This Package

Use `widgy_appwrite_context` when writing Appwrite Cloud Functions in Dart. It wraps the raw dynamic `context` object passed by the Appwrite runtime into typed classes with IDE autocompletion, compile-time safety, and convenience helpers.

**This package does NOT**:
- Depend on `dart_appwrite` SDK (they are independent)
- Provide networking, database, or file storage APIs
- Handle routing or middleware — the function author does that

## Installation

### CRITICAL: Private Pub Server — Legacy Hosted Format Required

Appwrite Dart runtime uses an outdated `pubspec` parser (v2.3.0). You **MUST** use the legacy `hosted` format. The modern shorthand will crash the Appwrite build system with `type 'Null' is not a subtype of type 'String'`.

**Correct (required for Appwrite deploy):**

```yaml
dependencies:
  widgy_appwrite_context:
    hosted:
      name: widgy_appwrite_context
      url: https://pub.widgy.io
    version: ^0.2.6
```

**Wrong (will break Appwrite build):**

```yaml
# DO NOT USE
dependencies:
  widgy_appwrite_context:
    hosted: https://pub.widgy.io
```

### Build Command for Private Pub

The function must have the `EASYFLUTTER_PUB_TOKEN` secret variable set in Appwrite Console. The build command must include token registration:

```
dart pub token add https://pub.widgy.io --env-var EASYFLUTTER_PUB_TOKEN && dart pub get
```

## Public API Surface

The package exports three top-level groups from `package:widgy_appwrite_context/widgy_appwrite_context.dart`:

| Export                     | Contains                                                                                                   |
| -------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `src/appwrite_logger.dart` | `AppwriteLogger` class, `awLog()` function, `awLogError()` function                                        |
| `src/enums/enums.dart`     | `AppwriteTrigger` enum, `HttpMethod` enum, `HttpScheme` enum                                               |
| `src/models/models.dart`   | `AppwriteContext`, `AppwriteEnvironment`, `AppwriteHeaders`, `AppwriteRequest`, `AppwriteResponse` classes |

Single import gives everything:

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';
```

---

## Core Classes Reference

### AppwriteContext

Entry point. Wraps the raw dynamic `context` from Appwrite runtime.

```dart
class AppwriteContext {
  factory AppwriteContext.initialize(dynamic context);

  final AppwriteRequest req;
  final AppwriteResponse res;
  final AppwriteEnvironment env;
}
```

**Usage:**

```dart
Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  // ctx.req  — typed request
  // ctx.res  — response builder
  // ctx.env  — environment variables
}
```

**Behavior:**
- `initialize()` also initializes `AppwriteLogger` internally, enabling `awLog()` and `awLogError()` globally.
- Constructor is private; only `initialize()` factory is public.

---

### AppwriteRequest

Typed representation of the incoming request. Created internally by `AppwriteContext.initialize()`.

#### Properties

| Property      | Type                   | Default            | Description                                           |
| ------------- | ---------------------- | ------------------ | ----------------------------------------------------- |
| `bodyText`    | `String`               | `''`               | Raw body as text                                      |
| `bodyJson`    | `Map<String, dynamic>` | `{}`               | Parsed JSON body. Empty map if body is not valid JSON |
| `bodyBinary`  | `Uint8List`            | `Uint8List(0)`     | Raw binary body data                                  |
| `headers`     | `AppwriteHeaders`      | —                  | Typed Appwrite-specific and standard HTTP headers     |
| `method`      | `HttpMethod`           | `HttpMethod.get`   | HTTP method enum                                      |
| `scheme`      | `HttpScheme`           | `HttpScheme.https` | HTTP scheme enum                                      |
| `url`         | `Uri`                  | `Uri()`            | Full URL as Uri object                                |
| `host`        | `String`               | `''`               | Hostname from host header                             |
| `port`        | `int`                  | `0`                | Port from host header                                 |
| `path`        | `String`               | `''`               | URL path (e.g., `/v1/hooks`)                          |
| `queryString` | `String`               | `''`               | Raw query string (e.g., `limit=12&offset=50`)         |
| `query`       | `Map<String, dynamic>` | `{}`               | Parsed query parameters                               |

#### Computed Getters

| Getter          | Type     | Description                         |
| --------------- | -------- | ----------------------------------- |
| `urlString`     | `String` | URL as string representation        |
| `hasBodyText`   | `bool`   | `true` if `bodyText` is non-empty   |
| `hasBodyJson`   | `bool`   | `true` if `bodyJson` is non-empty   |
| `hasBodyBinary` | `bool`   | `true` if `bodyBinary` is non-empty |
| `hasQuery`      | `bool`   | `true` if `query` is non-empty      |

#### Methods

| Method       | Return Type            | Description                                                                                     |
| ------------ | ---------------------- | ----------------------------------------------------------------------------------------------- |
| `toMap()`    | `Map<String, dynamic>` | Serializes request to a map (method, url, scheme, host, port, path, headers, hasBody, hasQuery) |
| `toString()` | `String`               | Pretty-printed or compact string via `PrettyToStringMixin`                                      |

---

### AppwriteHeaders

Typed wrapper for all HTTP headers. Separates Appwrite-specific headers, standard HTTP headers, and custom headers.

#### Appwrite-Specific Headers

| Property        | Type              | Header Key                  | Description                                                                      |
| --------------- | ----------------- | --------------------------- | -------------------------------------------------------------------------------- |
| `trigger`       | `AppwriteTrigger` | `x-appwrite-trigger`        | How the function was invoked: `http`, `schedule`, or `event`. Defaults to `http` |
| `event`         | `String?`         | `x-appwrite-event`          | Event string if triggered by event (e.g., `users.*.delete`). `null` if empty     |
| `apiKey`        | `String`          | `x-appwrite-key`            | Dynamic API key for server authentication. Always present                        |
| `userId`        | `String?`         | `x-appwrite-user-id`        | Authenticated user ID. `null` if not authenticated                               |
| `userJwt`       | `String?`         | `x-appwrite-user-jwt`       | JWT from invoking user's session. `null` if no session                           |
| `countryCode`   | `String?`         | `x-appwrite-country-code`   | Country code of client locale. `null` if unavailable                             |
| `continentCode` | `String?`         | `x-appwrite-continent-code` | Continent code. `null` if unavailable                                            |
| `isInEU`        | `bool`            | `x-appwrite-continent-eu`   | `true` if client is in EU                                                        |
| `clientIp`      | `String`          | `x-appwrite-client-ip`      | Client IP address. Always present                                                |
| `executionId`   | `String`          | `x-appwrite-execution-id`   | Current execution ID. Always present                                             |

#### Standard HTTP Headers

| Property        | Type      | Header Key       | Description                                 |
| --------------- | --------- | ---------------- | ------------------------------------------- |
| `authorization` | `String?` | `authorization`  | Authorization header. `null` if not present |
| `contentType`   | `String?` | `content-type`   | Content type. `null` if not present         |
| `contentLength` | `int`     | `content-length` | Body length in bytes. `0` if not present    |
| `accept`        | `String?` | `accept`         | Accept header. `null` if not present        |
| `host`          | `String?` | `host`           | Host header. `null` if not present          |
| `cookie`        | `String?` | `cookie`         | Cookie header. `null` if not present        |
| `cacheControl`  | `String?` | `cache-control`  | Cache-Control. `null` if not present        |
| `forwarded`     | `String?` | `forwarded`      | Forwarded header. `null` if not present     |
| `userAgent`     | `String?` | `user-agent`     | User-Agent. `null` if not present           |
| `referer`       | `String?` | `referer`        | Referer header. `null` if not present       |
| `origin`        | `String?` | `origin`         | Origin header. `null` if not present        |

#### Custom Headers

| Property        | Type                  | Description                                                                           |
| --------------- | --------------------- | ------------------------------------------------------------------------------------- |
| `customHeaders` | `Map<String, String>` | All headers that are NOT Appwrite-specific and NOT standard HTTP headers listed above |

#### Helper Getters

| Getter              | Type                   | Description                               |
| ------------------- | ---------------------- | ----------------------------------------- |
| `isHttpTrigger`     | `bool`                 | `trigger == AppwriteTrigger.http`         |
| `isScheduleTrigger` | `bool`                 | `trigger == AppwriteTrigger.schedule`     |
| `isEventTrigger`    | `bool`                 | `trigger == AppwriteTrigger.event`        |
| `hasUser`           | `bool`                 | `userId != null`                          |
| `hasUserJwt`        | `bool`                 | `userJwt != null`                         |
| `hasEvent`          | `bool`                 | `event != null`                           |
| `hasCustomHeaders`  | `bool`                 | `customHeaders.isNotEmpty`                |
| `hasAuthorization`  | `bool`                 | `authorization != null`                   |
| `hasContentType`    | `bool`                 | `contentType != null`                     |
| `asMap`             | `Map<String, dynamic>` | All headers as map (includes null values) |
| `asMapNonNull`      | `Map<String, dynamic>` | Only headers with non-null values         |

#### Methods

| Method       | Return Type            | Description                                                 |
| ------------ | ---------------------- | ----------------------------------------------------------- |
| `toMap()`    | `Map<String, dynamic>` | Full map of all headers including custom headers if present |
| `toString()` | `String`               | Pretty or compact string (via `PrettyToStringMixin`)        |

---

### AppwriteResponse

Response builder. Wraps the Appwrite runtime `context.res` object. All methods return `AppwriteResponseResult` (alias for `dynamic` — required by Appwrite runtime).

#### Core Response Methods

| Method     | Signature                                                                      | Status Code         | Content-Type                | Description             |
| ---------- | ------------------------------------------------------------------------------ | ------------------- | --------------------------- | ----------------------- |
| `json`     | `json(Map<String, dynamic> data, {int statusCode = 200})`                      | custom              | `application/json`          | JSON response           |
| `text`     | `text(String body, {int statusCode = 200, Map<String, String>? headers})`      | custom              | `text/plain; charset=utf-8` | Plain text response     |
| `html`     | `html(String body, {int statusCode = 200})`                                    | custom              | `text/html; charset=utf-8`  | HTML response           |
| `binary`   | `binary(Uint8List data, {int statusCode = 200, Map<String, String>? headers})` | custom              | per headers                 | Binary data response    |
| `empty`    | `empty()`                                                                      | 204                 | none                        | Empty response, no body |
| `redirect` | `redirect(String url, {int statusCode = 302})`                                 | 301/302/303/307/308 | none                        | HTTP redirect           |

#### Success Helpers

| Method      | Signature                                                                     | Status Code | Description                                                          |
| ----------- | ----------------------------------------------------------------------------- | ----------- | -------------------------------------------------------------------- |
| `ok`        | `ok(Map<String, dynamic> data)`                                               | 200         | Standard success                                                     |
| `created`   | `created(Map<String, dynamic> data)`                                          | 201         | Resource created                                                     |
| `accepted`  | `accepted([Map<String, dynamic>? data])`                                      | 202         | Accepted for async processing. Defaults to `{'message': 'Accepted'}` |
| `noContent` | `noContent()`                                                                 | 204         | Alias for `empty()`                                                  |
| `success`   | `success(String message, {Map<String, dynamic>? data, int statusCode = 200})` | custom      | Standard success format: `{success: true, message, data?}`           |

#### Error Helpers

| Method                | Signature                                                                                        | Status Code | Response Body Format                                                         |
| --------------------- | ------------------------------------------------------------------------------------------------ | ----------- | ---------------------------------------------------------------------------- |
| `badRequest`          | `badRequest(String message, {Map<String, dynamic>? details})`                                    | 400         | `{error: 'Bad Request', message, details?}`                                  |
| `unauthorized`        | `unauthorized([String message = 'Authentication required'])`                                     | 401         | `{error: 'Unauthorized', message}`                                           |
| `forbidden`           | `forbidden([String message = 'Access forbidden'])`                                               | 403         | `{error: 'Forbidden', message}`                                              |
| `notFound`            | `notFound([String resource = 'Resource'])`                                                       | 404         | `{error: 'Not Found', message: '$resource not found'}`                       |
| `methodNotAllowed`    | `methodNotAllowed([List<String>? allowed])`                                                      | 405         | `{error: 'Method Not Allowed', message}` — lists allowed methods if provided |
| `conflict`            | `conflict(String message)`                                                                       | 409         | `{error: 'Conflict', message}`                                               |
| `unprocessableEntity` | `unprocessableEntity(String message, {Map<String, dynamic>? errors})`                            | 422         | `{error: 'Unprocessable Entity', message, errors?}`                          |
| `validationError`     | `validationError(Map<String, List<String>> fieldErrors, {String message = 'Validation failed'})` | 422         | `{error: 'Validation Error', message, errors: fieldErrors}`                  |
| `tooManyRequests`     | `tooManyRequests({String message = 'Too many requests', int? retryAfter})`                       | 429         | `{error: 'Too Many Requests', message, retryAfter?}`                         |
| `internalError`       | `internalError({String message = 'Internal server error', Map<String, dynamic>? data})`          | 500         | `{error: 'Internal Server Error', message, data?}`                           |
| `serviceUnavailable`  | `serviceUnavailable({String message = 'Service temporarily unavailable', int? retryAfter})`      | 503         | `{error: 'Service Unavailable', message, retryAfter?}`                       |

#### File Download Helpers

| Method         | Signature                                                           | Description                                                                                                            |
| -------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `downloadFile` | `downloadFile(Uint8List data, String filename, {String? mimeType})` | Binary file download. Sets `Content-Disposition: attachment; filename="..."`. Default MIME: `application/octet-stream` |
| `downloadJSON` | `downloadJSON(Map<String, dynamic> data, String filename)`          | JSON file download. Serializes map to JSON bytes, sets `application/json` MIME                                         |

#### Custom Response

| Method | Signature                                                                          | Description                          |
| ------ | ---------------------------------------------------------------------------------- | ------------------------------------ |
| `send` | `send({required String body, int statusCode = 200, Map<String, String>? headers})` | Full control — delegates to `text()` |

---

### AppwriteEnvironment

Typed access to Appwrite Cloud Functions environment variables. Uses `Platform.environment` by default, but accepts a custom map for testing.

#### Constructor

```dart
const AppwriteEnvironment({Map<String, String>? environment});
```

- If `environment` is `null`, reads from `Platform.environment` (production behavior).
- If `environment` is provided, uses it instead (testing behavior).

#### Properties

| Property          | Type      | Environment Variable                | Availability | Description                                                                              |
| ----------------- | --------- | ----------------------------------- | ------------ | ---------------------------------------------------------------------------------------- |
| `apiEndpoint`     | `String`  | `APPWRITE_FUNCTION_API_ENDPOINT`    | Build + Run  | API endpoint URL (e.g., `https://cloud.appwrite.io/v1`)                                  |
| `appwriteVersion` | `String`  | `APPWRITE_VERSION`                  | Build + Run  | Appwrite version (e.g., `1.4.0`)                                                         |
| `region`          | `String`  | `APPWRITE_REGION`                   | Build + Run  | Function region (e.g., `default`)                                                        |
| `apiKey`          | `String?` | `APPWRITE_FUNCTION_API_KEY`         | Build only   | Function API key. **Null at runtime** — use `ctx.req.headers.apiKey` instead for runtime |
| `functionId`      | `String`  | `APPWRITE_FUNCTION_ID`              | Build + Run  | Current function ID                                                                      |
| `functionName`    | `String`  | `APPWRITE_FUNCTION_NAME`            | Build + Run  | Current function name                                                                    |
| `deployment`      | `String`  | `APPWRITE_FUNCTION_DEPLOYMENT`      | Build + Run  | Current deployment ID                                                                    |
| `projectId`       | `String`  | `APPWRITE_FUNCTION_PROJECT_ID`      | Build + Run  | Project ID                                                                               |
| `runtimeName`     | `String`  | `APPWRITE_FUNCTION_RUNTIME_NAME`    | Build + Run  | Runtime name (e.g., `dart-3.0`)                                                          |
| `runtimeVersion`  | `String`  | `APPWRITE_FUNCTION_RUNTIME_VERSION` | Build + Run  | Runtime version (e.g., `3.0.0`)                                                          |

#### Convenience Getters

| Getter         | Type                   | Description                                                      |
| -------------- | ---------------------- | ---------------------------------------------------------------- |
| `asMap`        | `Map<String, String?>` | All environment variables as map. **API key is masked as `***`** |
| `asMapNonNull` | `Map<String, String>`  | Only non-null environment variables                              |

#### Methods

| Method       | Return Type            | Description                  |
| ------------ | ---------------------- | ---------------------------- |
| `toMap()`    | `Map<String, String?>` | Full map with masked API key |
| `toString()` | `String`               | `AppwriteEnvironment{...}`   |

#### Important: apiKey at Build vs Runtime

- `env.apiKey` (from `APPWRITE_FUNCTION_API_KEY`) is available only at **build time**.
- At **runtime**, use `ctx.req.headers.apiKey` (from `x-appwrite-key` header) for server authentication.

**Correct pattern for creating Appwrite client:**

```dart
final client = Client()
    .setEndpoint(ctx.env.apiEndpoint)
    .setProject(ctx.env.projectId)
    .setKey(ctx.req.headers.apiKey);  // NOT ctx.env.apiKey
```

---

## Logging

### AppwriteLogger

Singleton logger initialized by `AppwriteContext.initialize()`. Do NOT instantiate manually.

```dart
class AppwriteLogger {
  static bool prettyPrint = true;  // Enable/disable JSON indentation
}
```

### Top-level Functions

| Function     | Signature                                     | Description                                                                               |
| ------------ | --------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `awLog`      | `awLog(Object? message, [Object? data])`      | Log to Appwrite Console. One arg: logs message. Two args: logs label then data separately |
| `awLogError` | `awLogError(Object? message, [Object? data])` | Log error to Appwrite Console. Same dual-mode as `awLog`                                  |

**Behavior:**
- Maps and Lists are pretty-printed as indented JSON when `AppwriteLogger.prettyPrint` is `true` (default).
- Strings are logged as-is.
- `null` is logged as empty string.
- If JSON encoding fails, falls back to `toString()`.

**Examples:**

```dart
awLog('Function started');
awLog('Body:', ctx.req.bodyJson);      // logs label, then pretty JSON
awLogError('Failed:', exception);       // logs label, then error
AppwriteLogger.prettyPrint = false;     // compact output
```

---

## Enums

### HttpMethod

| Value                | `.value`    | Description                    |
| -------------------- | ----------- | ------------------------------ |
| `HttpMethod.get`     | `'GET'`     | Retrieve data                  |
| `HttpMethod.post`    | `'POST'`    | Create data                    |
| `HttpMethod.put`     | `'PUT'`     | Update/replace data            |
| `HttpMethod.patch`   | `'PATCH'`   | Partially update data          |
| `HttpMethod.delete`  | `'DELETE'`  | Remove data                    |
| `HttpMethod.options` | `'OPTIONS'` | Describe communication options |
| `HttpMethod.head`    | `'HEAD'`    | Retrieve headers only          |

**Extension:** `HttpMethodExtension.parse(String?)` — parses string to enum. Defaults to `HttpMethod.get`.

### HttpScheme

| Value              | `.value`  | `.isSecure` | Description    |
| ------------------ | --------- | ----------- | -------------- |
| `HttpScheme.http`  | `'http'`  | `false`     | HTTP           |
| `HttpScheme.https` | `'https'` | `true`      | HTTPS (secure) |

**Extension:** `HttpSchemeExtension.parse(String?)` — parses string to enum. Defaults to `HttpScheme.https` for security.

### AppwriteTrigger

| Value                      | `.value`     | Description                      |
| -------------------------- | ------------ | -------------------------------- |
| `AppwriteTrigger.http`     | `'HTTP'`     | Triggered by HTTP request        |
| `AppwriteTrigger.schedule` | `'SCHEDULE'` | Triggered by scheduled execution |
| `AppwriteTrigger.event`    | `'EVENT'`    | Triggered by Appwrite event      |

**Extension:** `AppwriteTriggerExtension.parse(String?)` — parses string to enum. Defaults to `AppwriteTrigger.http`.

---

## Mixin: PrettyToStringMixin

Used by `AppwriteRequest` and `AppwriteHeaders`. Requires implementing `toMap()`. Overrides `toString()` to produce:
- Indented JSON when `AppwriteLogger.prettyPrint == true`
- Compact map string when `false`

---

## Utility Function

```dart
String messageToString(Object? message);
```

Converts any object to string. Returns `''` for `null`, passes through `String`, calls `toString()` on everything else. Internal utility, but exported.

---

## Complete Code Patterns

### Minimal Cloud Function

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  return ctx.res.json({'message': 'Hello from Appwrite!'});
}
```

### HTTP Trigger with Path Routing

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);

  final client = Client()
      .setEndpoint(ctx.env.apiEndpoint)
      .setProject(ctx.env.projectId)
      .setKey(ctx.req.headers.apiKey);

  return switch (ctx.req.path) {
    '/users' => _handleUsers(ctx, client),
    '/health' => ctx.res.ok({'status': 'healthy'}),
    _ => ctx.res.notFound('Endpoint'),
  };
}
```

### Event Trigger Routing

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  final trigger = ctx.req.headers.trigger;
  final event = ctx.req.headers.event;

  final client = Client()
      .setEndpoint(ctx.env.apiEndpoint)
      .setProject(ctx.env.projectId)
      .setKey(ctx.req.headers.apiKey);

  if (trigger == AppwriteTrigger.event && event != null) {
    if (event.contains('.documents.') && event.endsWith('.create')) {
      return _handleDocumentCreate(ctx, client);
    }
    return ctx.res.json({'ok': true, 'message': 'Unhandled event'});
  }

  if (trigger == AppwriteTrigger.http) {
    return switch (ctx.req.path) {
      '/ping' => ctx.res.ok({'pong': true}),
      _ => ctx.res.notFound('Endpoint'),
    };
  }

  return ctx.res.badRequest('Unknown trigger');
}
```

### Handler Pattern (Recommended)

Each handler is a standalone function receiving `AppwriteContext` and `Client`:

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

Future<AppwriteResponseResult> handleCreateUser(
  AppwriteContext ctx,
  Client client,
) async {
  try {
    if (ctx.req.method != HttpMethod.post) {
      return ctx.res.methodNotAllowed(['POST']);
    }

    final body = ctx.req.bodyJson;
    if (!body.containsKey('email')) {
      return ctx.res.badRequest('Missing email', details: {'email': 'required'});
    }

    final users = Users(client);
    final user = await users.create(
      userId: ID.unique(),
      email: body['email'] as String,
      password: body['password'] as String,
    );

    return ctx.res.created({'id': user.$id, 'email': user.email});
  } catch (e, stackTrace) {
    awLogError('Create user failed:', e);
    awLogError('Stack:', stackTrace);
    return ctx.res.internalError(message: e.toString());
  }
}
```

### Authentication Guard

```dart
if (!ctx.req.headers.hasUser) {
  return ctx.res.unauthorized();
}
final userId = ctx.req.headers.userId!;
```

### Validation Pattern

```dart
final body = ctx.req.bodyJson;
final errors = <String, List<String>>{};

if (!body.containsKey('email')) {
  errors['email'] = ['Email is required'];
}
if (!body.containsKey('password')) {
  errors['password'] = ['Password is required'];
}

if (errors.isNotEmpty) {
  return ctx.res.validationError(errors);
}
```

### Testing with Custom Environment

```dart
final testEnv = AppwriteEnvironment(environment: {
  'APPWRITE_FUNCTION_ID': 'test-func',
  'APPWRITE_FUNCTION_PROJECT_ID': 'test-project',
  'APPWRITE_FUNCTION_API_ENDPOINT': 'https://test.appwrite.io/v1',
  'APPWRITE_FUNCTION_NAME': 'test-function',
});

expect(testEnv.functionId, 'test-func');
expect(testEnv.projectId, 'test-project');
```

---

## File Structure

```
lib/
├── widgy_appwrite_context.dart              # Barrel export (single import)
└── src/
    ├── appwrite_logger.dart           # AppwriteLogger, awLog(), awLogError()
    ├── utils.dart                     # messageToString() utility
    ├── enums/
    │   ├── enums.dart                 # Barrel export for enums
    │   ├── appwrite_trigger.dart      # AppwriteTrigger enum + extension
    │   ├── http_method.dart           # HttpMethod enum + extension
    │   └── http_scheme.dart           # HttpScheme enum + extension
    ├── mixins/
    │   ├── mixins.dart                # Barrel export for mixins
    │   └── pretty_to_string_mixin.dart # PrettyToStringMixin
    └── models/
        ├── models.dart                # Barrel export for models
        ├── widgy_appwrite_context.dart      # AppwriteContext class
        ├── appwrite_environment.dart  # AppwriteEnvironment class
        ├── appwrite_headers.dart      # AppwriteHeaders class
        ├── appwrite_request.dart      # AppwriteRequest class
        └── appwrite_response.dart     # AppwriteResponse class
```

## Dependencies

- **Runtime**: none (only `dart:io`, `dart:convert`, `dart:typed_data`)
- **Dev only**: `test`, `mocktail`, `very_good_analysis`

---

## Key Gotchas and Warnings

1. **Legacy pubspec hosted format** is mandatory. Modern shorthand crashes Appwrite build.
2. **`env.apiKey` is build-time only**. At runtime use `ctx.req.headers.apiKey`.
3. **`AppwriteLogger` must be initialized** via `AppwriteContext.initialize()` before `awLog()`/`awLogError()` work. Calling them before initialization results in no-op (null instance).
4. **All parsing is null-safe with defaults**: missing method defaults to `GET`, missing scheme to `HTTPS`, missing trigger to `http`, missing port to `0`, missing strings to `''`, missing maps to `{}`.
5. **Response methods delegate to the raw Appwrite runtime `context.res`**. The package does not mock or intercept the actual HTTP response — it only provides typed wrappers and convenience methods.
6. **`AppwriteResponseResult` is `dynamic`**. This is required by the Appwrite runtime contract. The `typedef` exists for semantic clarity only.
