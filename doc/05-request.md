# Запрос и заголовки

## AppwriteRequest

Создаётся внутри `AppwriteContext.initialize()`. Все поля имеют значения
по умолчанию: отсутствующий метод — `GET`, отсутствующая схема —
`HTTPS`, пустое тело — пустая строка. Проверок на `null` в вашем коде не
требуется.

| Свойство | Тип | По умолчанию | Что это |
| --- | --- | --- | --- |
| `bodyText` | `String` | `''` | Тело как текст |
| `bodyJson` | `Map<String, dynamic>` | `{}` | Разобранный JSON; пустая карта, если тело не JSON |
| `bodyBinary` | `Uint8List` | пустой | Двоичное тело |
| `headers` | `AppwriteHeaders` | — | Заголовки, разложенные по типам |
| `method` | `HttpMethod` | `get` | Метод HTTP |
| `scheme` | `HttpScheme` | `https` | Схема |
| `url` | `Uri` | `Uri()` | Полный адрес |
| `host` | `String` | `''` | Имя узла |
| `port` | `int` | `0` | Порт |
| `path` | `String` | `''` | Путь, например `/v1/hooks` |
| `queryString` | `String` | `''` | Строка запроса как есть |
| `query` | `Map<String, dynamic>` | `{}` | Разобранные параметры |

Проверки наличия: `hasBodyText`, `hasBodyJson`, `hasBodyBinary`,
`hasQuery`, а также `urlString` — адрес строкой.

## AppwriteHeaders

Заголовки разложены на три группы: свои у Appwrite, стандартные HTTP и
всё остальное.

### Заголовки Appwrite

| Свойство | Тип | Заголовок | Что это |
| --- | --- | --- | --- |
| `trigger` | `AppwriteTrigger` | `x-appwrite-trigger` | Как вызвана функция: `http`, `schedule`, `event` |
| `event` | `String?` | `x-appwrite-event` | Событие, например `users.*.delete` |
| `apiKey` | `String` | `x-appwrite-key` | Динамический ключ для серверных вызовов |
| `userId` | `String?` | `x-appwrite-user-id` | Кто вызвал; `null`, если не авторизован |
| `userJwt` | `String?` | `x-appwrite-user-jwt` | JWT сессии вызвавшего |
| `countryCode` | `String?` | `x-appwrite-country-code` | Код страны клиента |
| `continentCode` | `String?` | `x-appwrite-continent-code` | Код континента |
| `isInEU` | `bool` | `x-appwrite-continent-eu` | Клиент в ЕС |
| `clientIp` | `String` | `x-appwrite-client-ip` | Адрес клиента |
| `executionId` | `String` | `x-appwrite-execution-id` | Идентификатор запуска |

### Стандартные заголовки

`authorization`, `contentType`, `contentLength`, `accept`, `host`,
`cookie`, `cacheControl`, `forwarded`, `userAgent`, `referer`, `origin`.
Все строковые — `String?`, кроме `contentLength`, который `int` и равен
нулю при отсутствии.

### Остальные

`customHeaders` — карта всего, что не попало в две группы выше. Ваши
собственные заголовки искать здесь.

### Проверки

`isHttpTrigger`, `isScheduleTrigger`, `isEventTrigger`, `hasUser`,
`hasUserJwt`, `hasEvent`, `hasCustomHeaders`, `hasAuthorization`,
`hasContentType`.

Плюс `asMap` — все заголовки картой, и `asMapNonNull` — только
заполненные.
