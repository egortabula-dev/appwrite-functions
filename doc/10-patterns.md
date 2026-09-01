# Рецепты

## Обработчик отдельной функцией

Рекомендуемая форма: `main` только маршрутизирует, каждый обработчик —
самостоятельная функция, принимающая контекст и клиент. Так обработчик
можно проверить тестом, не поднимая среду Appwrite.

```dart
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
      return ctx.res.badRequest('Нет поля email', details: {'email': 'обязательно'});
    }

    final user = await Users(client).create(
      userId: ID.unique(),
      email: body['email'] as String,
      password: body['password'] as String,
    );

    return ctx.res.created({'id': user.$id, 'email': user.email});
  } catch (e, stackTrace) {
    awLogError('Создание пользователя не удалось:', e);
    awLogError('Стек:', stackTrace);
    return ctx.res.internalError(message: e.toString());
  }
}
```

## Проверка авторизации

```dart
if (!ctx.req.headers.hasUser) return ctx.res.unauthorized();

final userId = ctx.req.headers.userId!;
```

Восклицательный знак здесь безопасен ровно потому, что стоит после
`hasUser`.

## Проверка полей

```dart
final body = ctx.req.bodyJson;
final errors = <String, List<String>>{};

if (!body.containsKey('email')) errors['email'] = ['Обязательное поле'];
if (!body.containsKey('password')) errors['password'] = ['Обязательное поле'];

if (errors.isNotEmpty) return ctx.res.validationError(errors);
```

Собирать все ошибки разом, а не отвечать на первой: иначе пользователь
исправляет форму по одному полю за запрос.

## Тесты

Контекст создаётся только из объекта среды, поэтому в тестах проверяют
обработчики и окружение, а не `main`:

```dart
const env = AppwriteEnvironment(environment: {
  'APPWRITE_FUNCTION_ID': 'test-func',
  'APPWRITE_FUNCTION_PROJECT_ID': 'test-project',
});

expect(env.functionId, 'test-func');
```
