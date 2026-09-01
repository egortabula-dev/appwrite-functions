# Быстрый старт

## Минимальная функция

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  return ctx.res.json({'message': 'Привет из Appwrite!'});
}
```

`initialize()` разбирает сырой контекст и заодно включает
журналирование — после него работают `awLog()` и `awLogError()`.

## Маршрутизация по пути

Appwrite не маршрутизирует за вас: одна функция получает все запросы, и
разбор пути — ваша работа. С типизированным запросом это выражение, а не
дерево `if`.

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
    _ => ctx.res.notFound('Маршрут'),
  };
}
```

Обратите внимание на ключ: `ctx.req.headers.apiKey`, а не
`ctx.env.apiKey`. Почему — в разделе [Окружение](../environment/).

## Разные способы запуска

Одну и ту же функцию Appwrite вызывает по HTTP, по расписанию и по
событию. Что именно произошло, написано в заголовках:

```dart
Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  final headers = ctx.req.headers;

  if (headers.isEventTrigger && headers.hasEvent) {
    final event = headers.event!;
    if (event.contains('.documents.') && event.endsWith('.create')) {
      return _handleDocumentCreate(ctx);
    }
    return ctx.res.ok({'message': 'Событие не обрабатывается'});
  }

  if (headers.isScheduleTrigger) return _runNightlyJob(ctx);

  return switch (ctx.req.path) {
    '/ping' => ctx.res.ok({'pong': true}),
    _ => ctx.res.notFound('Маршрут'),
  };
}
```
