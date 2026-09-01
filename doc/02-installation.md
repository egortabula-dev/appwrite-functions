# Установка

## Формат зависимости: только старый

Среда выполнения Dart в Appwrite использует устаревший разборщик
`pubspec` (версии 2.3.0). Он **не понимает** современную короткую запись
приватного реестра, и сборка функции падает с

```
type 'Null' is not a subtype of type 'String'
```

Ошибка ничего не говорит о причине, поэтому запомните форму записи.

**Так надо:**

```yaml
dependencies:
  widgy_appwrite_context:
    hosted:
      name: widgy_appwrite_context
      url: https://pub.widgy.io
    version: ^0.2.6
```

**Так сборка сломается:**

```yaml
dependencies:
  widgy_appwrite_context:
    hosted: https://pub.widgy.io
```

Разница только в том, что во втором случае `hosted` — строка, а не
объект. Современный `pub` понимает обе записи, разборщик Appwrite —
только первую.

## Токен реестра

Пакеты Widgy ставятся по токену. В консоли Appwrite задайте секретную
переменную `WIDGY_PUB_TOKEN` со значением вашего токена, а в команду
сборки функции добавьте его регистрацию:

```
dart pub token add https://pub.widgy.io --env-var WIDGY_PUB_TOKEN && dart pub get
```

Без первой команды `dart pub get` получит 401 и сборка остановится.

## Один импорт

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';
```

Он даёт всё: модели, перечисления и журналирование.
