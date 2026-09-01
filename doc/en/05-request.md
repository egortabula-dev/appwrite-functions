# Request and headers

## AppwriteRequest

Created inside `AppwriteContext.initialize()`. Every field has a default:
a missing method is `GET`, a missing scheme is `HTTPS`, an empty body is
an empty string. No null checks needed in your code.

| Property | Type | Default | What it is |
| --- | --- | --- | --- |
| `bodyText` | `String` | `''` | Body as text |
| `bodyJson` | `Map<String, dynamic>` | `{}` | Parsed JSON; empty map when the body is not JSON |
| `bodyBinary` | `Uint8List` | empty | Binary body |
| `headers` | `AppwriteHeaders` | — | Headers, sorted by kind |
| `method` | `HttpMethod` | `get` | HTTP method |
| `scheme` | `HttpScheme` | `https` | Scheme |
| `url` | `Uri` | `Uri()` | Full URL |
| `host` | `String` | `''` | Host name |
| `port` | `int` | `0` | Port |
| `path` | `String` | `''` | Path, e.g. `/v1/hooks` |
| `queryString` | `String` | `''` | Raw query string |
| `query` | `Map<String, dynamic>` | `{}` | Parsed query parameters |

Presence checks: `hasBodyText`, `hasBodyJson`, `hasBodyBinary`,
`hasQuery`, plus `urlString` for the URL as text.

## AppwriteHeaders

Headers come in three groups: Appwrite's own, standard HTTP, and
everything else.

### Appwrite headers

| Property | Type | Header | What it is |
| --- | --- | --- | --- |
| `trigger` | `AppwriteTrigger` | `x-appwrite-trigger` | How the function was invoked: `http`, `schedule`, `event` |
| `event` | `String?` | `x-appwrite-event` | The event, e.g. `users.*.delete` |
| `apiKey` | `String` | `x-appwrite-key` | Dynamic key for server calls |
| `userId` | `String?` | `x-appwrite-user-id` | Who called; `null` when unauthenticated |
| `userJwt` | `String?` | `x-appwrite-user-jwt` | JWT of the caller's session |
| `countryCode` | `String?` | `x-appwrite-country-code` | Client country |
| `continentCode` | `String?` | `x-appwrite-continent-code` | Client continent |
| `isInEU` | `bool` | `x-appwrite-continent-eu` | Client is in the EU |
| `clientIp` | `String` | `x-appwrite-client-ip` | Client address |
| `executionId` | `String` | `x-appwrite-execution-id` | Execution id |

### Standard headers

`authorization`, `contentType`, `contentLength`, `accept`, `host`,
`cookie`, `cacheControl`, `forwarded`, `userAgent`, `referer`, `origin`.
All are `String?` except `contentLength`, which is an `int` and zero when
absent.

### The rest

`customHeaders` holds everything that fell into neither group. Your own
headers live here.

### Checks

`isHttpTrigger`, `isScheduleTrigger`, `isEventTrigger`, `hasUser`,
`hasUserJwt`, `hasEvent`, `hasCustomHeaders`, `hasAuthorization`,
`hasContentType`.

Plus `asMap` for every header and `asMapNonNull` for the populated ones.
