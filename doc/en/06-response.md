# Response

`AppwriteResponse` wraps the runtime's `context.res`. Every method
returns `AppwriteResponseResult` — an alias for `dynamic`, required by
the Appwrite contract; the alias exists purely for readability.

## Core methods

| Method | Status | Content type |
| --- | --- | --- |
| `json(Map data, {int statusCode = 200})` | any | `application/json` |
| `text(String body, {int statusCode = 200, Map<String, String>? headers})` | any | `text/plain; charset=utf-8` |
| `html(String body, {int statusCode = 200})` | any | `text/html; charset=utf-8` |
| `binary(Uint8List data, {int statusCode = 200, Map<String, String>? headers})` | any | per headers |
| `empty()` | 204 | no body |
| `redirect(String url, {int statusCode = 302})` | 301–308 | no body |

## Success

| Method | Status | What it returns |
| --- | --- | --- |
| `ok(Map data)` | 200 | The data as given |
| `created(Map data)` | 201 | Resource created |
| `accepted([Map? data])` | 202 | Accepted for async work; defaults to `{'message': 'Accepted'}` |
| `noContent()` | 204 | Same as `empty()` |
| `success(String message, {Map? data, int statusCode = 200})` | any | `{success: true, message, data?}` |

## Errors

They all share one shape: `{error, message, …}`. That matters more than
it looks — the client parses a failure the same way wherever it came
from.

| Method | Status | Body |
| --- | --- | --- |
| `badRequest(String message, {Map? details})` | 400 | `{error: 'Bad Request', message, details?}` |
| `unauthorized([String message])` | 401 | `{error: 'Unauthorized', message}` |
| `forbidden([String message])` | 403 | `{error: 'Forbidden', message}` |
| `notFound([String resource])` | 404 | `{error: 'Not Found', message: '$resource not found'}` |
| `methodNotAllowed([List<String>? allowed])` | 405 | Lists the allowed methods |
| `conflict(String message)` | 409 | `{error: 'Conflict', message}` |
| `unprocessableEntity(String message, {Map? errors})` | 422 | `{error: 'Unprocessable Entity', …}` |
| `validationError(Map<String, List<String>> fieldErrors, {String message})` | 422 | Errors per field |
| `tooManyRequests({String message, int? retryAfter})` | 429 | With a hint when to retry |
| `internalError({String message, Map? data})` | 500 | `{error: 'Internal Server Error', …}` |
| `serviceUnavailable({String message, int? retryAfter})` | 503 | Temporary failure |

## Files

| Method | What it does |
| --- | --- |
| `downloadFile(Uint8List data, String filename, {String? mimeType})` | Sends a file as an attachment; defaults to `application/octet-stream` |
| `downloadJSON(Map data, String filename)` | Serialises a map and sends it as an `application/json` file |

## Full control

```dart
ctx.res.send(body: 'anything', statusCode: 418, headers: {'X-Teapot': 'yes'});
```
