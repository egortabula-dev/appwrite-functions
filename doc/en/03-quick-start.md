# Quick start

## A minimal function

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  return ctx.res.json({'message': 'Hello from Appwrite!'});
}
```

`initialize()` parses the raw context and starts logging along the way —
`awLog()` and `awLogError()` work after it.

## Routing by path

Appwrite does not route for you: one function receives every request, and
splitting on the path is your job. With a typed request that is an
expression, not a tree of `if`s.

```dart
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

Note the key: `ctx.req.headers.apiKey`, not `ctx.env.apiKey`. Why, in
[Environment](../environment/).

## Different ways of being invoked

Appwrite calls the same function over HTTP, on a schedule and on an
event. Which one happened is in the headers:

```dart
Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  final headers = ctx.req.headers;

  if (headers.isEventTrigger && headers.hasEvent) {
    final event = headers.event!;
    if (event.contains('.documents.') && event.endsWith('.create')) {
      return _handleDocumentCreate(ctx);
    }
    return ctx.res.ok({'message': 'Unhandled event'});
  }

  if (headers.isScheduleTrigger) return _runNightlyJob(ctx);

  return switch (ctx.req.path) {
    '/ping' => ctx.res.ok({'pong': true}),
    _ => ctx.res.notFound('Endpoint'),
  };
}
```
