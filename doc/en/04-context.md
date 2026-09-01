# AppwriteContext

The entry point. Wraps the runtime's raw `context`.

```dart
class AppwriteContext {
  factory AppwriteContext.initialize(dynamic context);

  final AppwriteRequest req;
  final AppwriteResponse res;
  final AppwriteEnvironment env;
}
```

| Field | Type | What it gives |
| --- | --- | --- |
| `req` | `AppwriteRequest` | The parsed request: body, headers, method, path, query |
| `res` | `AppwriteResponse` | A response builder with ready-made success and error shapes |
| `env` | `AppwriteEnvironment` | The function's environment variables |

## Creating it

```dart
final ctx = AppwriteContext.initialize(context);
```

The ordinary constructor is private: a context can only be made from the
runtime object. That is not a restriction for its own sake — an
instance assembled by hand would have no link to the real `context.res`,
and the response would go nowhere.

`initialize()` also brings up logging, so it belongs on the first line:
before it, `awLog()` silently does nothing.
