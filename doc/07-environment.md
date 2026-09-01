# Окружение

`AppwriteEnvironment` даёт типизированный доступ к переменным окружения
функции. По умолчанию читает `Platform.environment`, но принимает свою
карту — на этом строится тестирование.

```dart
const AppwriteEnvironment({Map<String, String>? environment});
```

| Свойство | Переменная | Доступна | Что это |
| --- | --- | --- | --- |
| `apiEndpoint` | `APPWRITE_FUNCTION_API_ENDPOINT` | сборка и запуск | Адрес API |
| `appwriteVersion` | `APPWRITE_VERSION` | сборка и запуск | Версия Appwrite |
| `region` | `APPWRITE_REGION` | сборка и запуск | Регион |
| `apiKey` | `APPWRITE_FUNCTION_API_KEY` | **только сборка** | Ключ функции |
| `functionId` | `APPWRITE_FUNCTION_ID` | сборка и запуск | Идентификатор функции |
| `functionName` | `APPWRITE_FUNCTION_NAME` | сборка и запуск | Имя функции |
| `deployment` | `APPWRITE_FUNCTION_DEPLOYMENT` | сборка и запуск | Идентификатор развёртывания |
| `projectId` | `APPWRITE_FUNCTION_PROJECT_ID` | сборка и запуск | Проект |
| `runtimeName` | `APPWRITE_FUNCTION_RUNTIME_NAME` | сборка и запуск | Среда выполнения |
| `runtimeVersion` | `APPWRITE_FUNCTION_RUNTIME_VERSION` | сборка и запуск | Версия среды |

`asMap` отдаёт всё картой, **маскируя ключ** как `***`; `asMapNonNull` —
только заполненное. Маскировка не косметическая: карта окружения чаще
всего попадает именно в журнал.

## Ключ на сборке и ключ в запуске — разные

`env.apiKey` существует только во время сборки. В запущенной функции он
`null`, и клиент, созданный с ним, получит 401 на первом же вызове.

В рантайме ключ приходит заголовком `x-appwrite-key`:

```dart
final client = Client()
    .setEndpoint(ctx.env.apiEndpoint)
    .setProject(ctx.env.projectId)
    .setKey(ctx.req.headers.apiKey);  // не ctx.env.apiKey
```

Ошибка живучая: код собирается, тесты проходят, функция разворачивается —
и падает только на настоящем запросе.

## Подмена в тестах

```dart
const env = AppwriteEnvironment(environment: {
  'APPWRITE_FUNCTION_ID': 'test-func',
  'APPWRITE_FUNCTION_PROJECT_ID': 'test-project',
  'APPWRITE_FUNCTION_API_ENDPOINT': 'https://test.appwrite.io/v1',
});

expect(env.functionId, 'test-func');
```
