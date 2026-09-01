# Обзор

`widgy_appwrite_context` — типизированная обёртка над объектом `context`,
который среда Appwrite Cloud Functions передаёт в вашу функцию.

В сыром виде это `dynamic`: подсказок в редакторе нет, опечатка в имени
поля обнаруживается на боевом запуске, а разбор заголовков и тела
приходится писать заново в каждой функции. Пакет заменяет его классами с
автодополнением, значениями по умолчанию и проверками на этапе
компиляции.

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);

  if (!ctx.req.headers.hasUser) return ctx.res.unauthorized();

  return ctx.res.ok({'user': ctx.req.headers.userId});
}
```

## Когда применять

Когда вы пишете Cloud Functions на Dart. Всё, что делает пакет, —
раскладывает входящий запрос по типам и даёт удобный построитель ответа.

## Чего пакет не делает

- **Не зависит от `dart_appwrite`.** Клиент SDK вы создаёте сами; пакеты
  независимы и версионируются раздельно.
- **Не ходит в сеть и не работает с базой.** Это разбор входа и сборка
  выхода, не клиент Appwrite.
- **Не маршрутизирует.** Разбор пути и событий остаётся за автором
  функции — в [рецептах](../patterns/) показано, как это выглядит.

## Зависимости

В рантайме — никаких, только `dart:io`, `dart:convert` и
`dart:typed_data`. В разработке — `test`, `mocktail`,
`very_good_analysis`.
