# Ответ

`AppwriteResponse` оборачивает `context.res` среды выполнения. Все методы
возвращают `AppwriteResponseResult` — это псевдоним `dynamic`, которого
требует контракт Appwrite; сам псевдоним существует только ради
читаемости.

## Базовые методы

| Метод | Код | Тип содержимого |
| --- | --- | --- |
| `json(Map data, {int statusCode = 200})` | любой | `application/json` |
| `text(String body, {int statusCode = 200, Map<String, String>? headers})` | любой | `text/plain; charset=utf-8` |
| `html(String body, {int statusCode = 200})` | любой | `text/html; charset=utf-8` |
| `binary(Uint8List data, {int statusCode = 200, Map<String, String>? headers})` | любой | по заголовкам |
| `empty()` | 204 | без тела |
| `redirect(String url, {int statusCode = 302})` | 301–308 | без тела |

## Успех

| Метод | Код | Что отдаёт |
| --- | --- | --- |
| `ok(Map data)` | 200 | Данные как есть |
| `created(Map data)` | 201 | Ресурс создан |
| `accepted([Map? data])` | 202 | Принято в обработку; по умолчанию `{'message': 'Accepted'}` |
| `noContent()` | 204 | То же, что `empty()` |
| `success(String message, {Map? data, int statusCode = 200})` | любой | `{success: true, message, data?}` |

## Ошибки

Форма ответа одинакова у всех: `{error, message, …}`. Это важнее, чем
кажется: клиент разбирает ошибку одним способом независимо от того, где
она возникла.

| Метод | Код | Тело |
| --- | --- | --- |
| `badRequest(String message, {Map? details})` | 400 | `{error: 'Bad Request', message, details?}` |
| `unauthorized([String message])` | 401 | `{error: 'Unauthorized', message}` |
| `forbidden([String message])` | 403 | `{error: 'Forbidden', message}` |
| `notFound([String resource])` | 404 | `{error: 'Not Found', message: '$resource not found'}` |
| `methodNotAllowed([List<String>? allowed])` | 405 | Перечисляет разрешённые методы |
| `conflict(String message)` | 409 | `{error: 'Conflict', message}` |
| `unprocessableEntity(String message, {Map? errors})` | 422 | `{error: 'Unprocessable Entity', …}` |
| `validationError(Map<String, List<String>> fieldErrors, {String message})` | 422 | Ошибки по полям |
| `tooManyRequests({String message, int? retryAfter})` | 429 | С подсказкой, когда повторить |
| `internalError({String message, Map? data})` | 500 | `{error: 'Internal Server Error', …}` |
| `serviceUnavailable({String message, int? retryAfter})` | 503 | Временный отказ |

## Файлы

| Метод | Что делает |
| --- | --- |
| `downloadFile(Uint8List data, String filename, {String? mimeType})` | Отдаёт файл вложением; по умолчанию `application/octet-stream` |
| `downloadJSON(Map data, String filename)` | Сериализует карту и отдаёт файлом `application/json` |

## Полный контроль

```dart
ctx.res.send(body: 'что угодно', statusCode: 418, headers: {'X-Teapot': 'yes'});
```
