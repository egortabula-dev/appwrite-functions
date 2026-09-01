# Перечисления и утилиты

Все три перечисления разбирают строку расширением `parse` и **никогда не
падают**: неизвестное значение превращается в значение по умолчанию.

## HttpMethod

`get`, `post`, `put`, `patch`, `delete`, `options`, `head`. Строковое
представление — в `.value` (`'GET'`, `'POST'`…).

```dart
HttpMethodExtension.parse('POST');   // HttpMethod.post
HttpMethodExtension.parse(null);     // HttpMethod.get
```

## HttpScheme

`http` и `https`, у второго `isSecure == true`.

```dart
HttpSchemeExtension.parse(null);     // HttpScheme.https
```

По умолчанию именно `https`: если схема неизвестна, безопаснее считать
соединение защищённым и не строить логику на предположении об открытом
канале.

## AppwriteTrigger

`http`, `schedule`, `event` со значениями `'HTTP'`, `'SCHEDULE'`,
`'EVENT'`. По умолчанию `http`.

## PrettyToStringMixin

Подмешивается к `AppwriteRequest` и `AppwriteHeaders`. Требует
`toMap()` и переопределяет `toString()`: JSON с отступами, когда
`AppwriteLogger.prettyPrint` включён, и компактная запись, когда нет.

Отсюда следует приятное: объект запроса можно передать прямо в журнал.

```dart
awLog('Запрос:', ctx.req);
```

## messageToString

```dart
String messageToString(Object? message);
```

`null` превращает в пустую строку, строку отдаёт как есть, у остального
вызывает `toString()`. Внутренняя утилита, но экспортируется.
