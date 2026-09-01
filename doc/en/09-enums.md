# Enums and utilities

All three enums parse a string through a `parse` extension and **never
throw**: an unknown value becomes the default.

## HttpMethod

`get`, `post`, `put`, `patch`, `delete`, `options`, `head`. The string
form is in `.value` (`'GET'`, `'POST'`…).

```dart
HttpMethodExtension.parse('POST');   // HttpMethod.post
HttpMethodExtension.parse(null);     // HttpMethod.get
```

## HttpScheme

`http` and `https`, the latter with `isSecure == true`.

```dart
HttpSchemeExtension.parse(null);     // HttpScheme.https
```

`https` is the default deliberately: when the scheme is unknown it is
safer to assume the connection is secure than to build logic on the
assumption that it is open.

## AppwriteTrigger

`http`, `schedule`, `event`, with values `'HTTP'`, `'SCHEDULE'`,
`'EVENT'`. Defaults to `http`.

## PrettyToStringMixin

Mixed into `AppwriteRequest` and `AppwriteHeaders`. It requires
`toMap()` and overrides `toString()`: indented JSON when
`AppwriteLogger.prettyPrint` is on, a compact map when it is off.

Which makes one nice thing possible — passing the request straight to
the log.

```dart
awLog('Request:', ctx.req);
```

## messageToString

```dart
String messageToString(Object? message);
```

Turns `null` into an empty string, passes a `String` through, and calls
`toString()` on anything else. An internal utility, but exported.
