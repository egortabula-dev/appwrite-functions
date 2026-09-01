# AppwriteContext

Точка входа. Оборачивает сырой `context` среды выполнения.

```dart
class AppwriteContext {
  factory AppwriteContext.initialize(dynamic context);

  final AppwriteRequest req;
  final AppwriteResponse res;
  final AppwriteEnvironment env;
}
```

| Поле | Тип | Что даёт |
| --- | --- | --- |
| `req` | `AppwriteRequest` | Разобранный запрос: тело, заголовки, метод, путь, параметры |
| `res` | `AppwriteResponse` | Построитель ответа с готовыми формами успеха и ошибки |
| `env` | `AppwriteEnvironment` | Переменные окружения функции |

## Создание

```dart
final ctx = AppwriteContext.initialize(context);
```

Обычный конструктор закрыт: контекст создаётся только из сырого объекта
среды. Это не ограничение ради ограничения — объект, собранный вручную,
не имел бы связи с настоящим `context.res`, и ответ никуда бы не ушёл.

`initialize()` попутно поднимает журналирование, поэтому вызывать его
нужно первым делом: до него `awLog()` молча ничего не делает.
