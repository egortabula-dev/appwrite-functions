# appwrite_functions_context

[![style: lints][lints_badge]][lints_link]
[![Dart][dart_badge]][dart_link]
[![License: MIT][license_badge]][license_link]

> Appwrite hands your function an untyped `context`. This package hands you
> back a typed one.

A zero-dependency wrapper around the Appwrite Cloud Functions context: the
request, its headers, the response builders, and the environment — all typed,
all discoverable by autocompletion instead of by documentation.

## Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Request](#request)
- [Headers](#headers)
- [Response](#response)
- [Environment](#environment)
- [Logging](#logging)
- [Testing](#testing)

## Overview

An Appwrite function receives one dynamic object and returns whatever it
likes. That is flexible and unhelpful: `context.req.bodyJson` might be a map
or might not exist, `context.req.headers['x-appwrite-key']` is a string typed
by hope, and the only way to learn what else is in there is to read
Appwrite's source.

This package resolves that object once, at the top of the handler, into
typed pieces:

- `AppwriteRequest` — body in three forms, method, URL parts, query
- `AppwriteHeaders` — the `x-appwrite-*` headers by name, not by string key
- `AppwriteResponse` — response builders, including the common HTTP statuses
- `AppwriteEnvironment` — the `APPWRITE_*` variables the runtime injects
- `awLog` / `awLogError` — logging that survives being called before the
  context exists

It adds no dependencies. It is loaded by every function you write, so it has
no right to bring anything with it.

## Installation

```yaml
dependencies:
  appwrite_functions_context:
    git:
      url: https://github.com/egortabula/appwrite-functions.git
      path: packages/appwrite_functions_context
```

Requires Dart 3.8 or newer, which covers every Appwrite runtime from
`dart-3.8` up.

## Quick start

```dart
import 'package:appwrite_functions_context/appwrite_functions_context.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);

  if (ctx.req.method != HttpMethod.post) {
    return ctx.res.methodNotAllowed(['POST']);
  }

  final accountId = ctx.req.bodyJson['accountId'];
  if (accountId is! String || accountId.isEmpty) {
    return ctx.res.badRequest('accountId is required');
  }

  awLog('Deleting account $accountId');

  return ctx.res.ok({'deleted': accountId});
}
```

## Request

`ctx.req` — everything that arrived.

| Member | Type | Description |
|--------|------|-------------|
| `bodyText` | `String` | Raw body, empty when there is none |
| `bodyJson` | `Map<String, dynamic>` | Parsed body, empty map when unparseable |
| `bodyBinary` | `Uint8List` | Raw bytes, for uploads |
| `headers` | `AppwriteHeaders` | See below |
| `method` | `HttpMethod` | `get`, `post`, `put`, `patch`, `delete`, `options`, `head` |
| `scheme` | `HttpScheme` | `http` or `https` |
| `url` | `Uri` | Full request URL |
| `host` / `port` / `path` | `String` / `int` / `String` | URL parts |
| `query` | `Map<String, dynamic>` | Parsed query string |
| `queryString` | `String` | Raw query string |
| `hasBodyText` / `hasBodyJson` / `hasBodyBinary` / `hasQuery` | `bool` | Emptiness checks |

Parsing the body from `bodyText` rather than `bodyJson` is worth doing when
you need to tell "not JSON" from "JSON without the field" — the two are
different mistakes, and the caller deserves to know which one it made.

## Headers

`ctx.req.headers` — the Appwrite-specific headers, typed.

| Member | Type | Description |
|--------|------|-------------|
| `trigger` | `AppwriteTrigger` | `http`, `schedule` or `event` |
| `event` | `String?` | Event name when the trigger is an event |
| `apiKey` | `String` | The dynamic key Appwrite issues for this execution |
| `userId` | `String?` | Caller's user id, when a user is attached |
| `userJwt` | `String?` | Caller's JWT, when one was sent |
| `executionId` | `String` | This execution's id, for correlating logs |
| `clientIp` | `String` | Caller's address |
| `countryCode` / `continentCode` / `isInEU` | `String?` / `String?` / `bool` | Geography, as Appwrite resolved it |
| `contentType` / `contentLength` / `accept` / `authorization` | | Standard HTTP headers |

The `apiKey` is worth knowing about: Appwrite issues a key scoped to what the
function declared, alive only for this execution. Use it instead of storing
a key in a variable.

## Response

`ctx.res` — builders. The generic ones:

| Method | Status | Description |
|--------|--------|-------------|
| `json(data, {statusCode})` | 200 | JSON body |
| `text(body, {statusCode})` | 200 | Plain text |
| `html(body, {statusCode})` | 200 | HTML |
| `binary(bytes, {statusCode, headers})` | 200 | Raw bytes |
| `redirect(url, {statusCode})` | 302 | Redirect |
| `empty()` | 204 | No content |

And the named ones, which say the status out loud at the call site:

| Method | Status |
|--------|--------|
| `ok(data)` | 200 |
| `created(data)` | 201 |
| `accepted([data])` | 202 |
| `noContent()` | 204 |
| `badRequest(message)` | 400 |
| `unauthorized([message])` | 401 |
| `forbidden([message])` | 403 |
| `notFound([resource])` | 404 |
| `methodNotAllowed([allowed])` | 405 |
| `conflict(message)` | 409 |
| `unprocessableEntity(...)` | 422 |
| `tooManyRequests(...)` | 429 |
| `internalError(...)` | 500 |
| `serviceUnavailable(...)` | 503 |

## Environment

`ctx.env` — the variables the runtime injects, without the string keys.

| Member | Variable |
|--------|----------|
| `apiEndpoint` | `APPWRITE_FUNCTION_API_ENDPOINT` |
| `projectId` | `APPWRITE_FUNCTION_PROJECT_ID` |
| `functionId` / `functionName` | `APPWRITE_FUNCTION_ID` / `_NAME` |
| `deployment` | `APPWRITE_FUNCTION_DEPLOYMENT` |
| `runtimeName` / `runtimeVersion` | `APPWRITE_FUNCTION_RUNTIME_NAME` / `_VERSION` |
| `region` / `appwriteVersion` | `APPWRITE_REGION` / `APPWRITE_VERSION` |

One warning learned the hard way: `apiEndpoint` carries whatever scheme the
instance is configured with. A self-hosted Appwrite with
`_APP_OPTIONS_FORCE_HTTPS=disabled` hands functions an `http://` endpoint, a
proxy in front answers `301`, and an HTTP client following that redirect
turns a `DELETE` into a `GET` — every call reports success and nothing is
deleted. If your deletions silently do nothing, look here first.

## Logging

```dart
awLog('Processing', {'accountId': accountId});
awLogError('Could not clear tokens', error);
```

Both accept an optional second argument, pretty-printed next to the message.
They work whether or not the context has been initialized, so a failure
during startup still leaves a trace.

## Testing

```sh
dart test
```

The context is built from a plain dynamic object, so tests need no Appwrite:
pass a stub with `req`, `res` and `headers` and assert on what the wrapper
made of it.

<!-- Badge references -->
[lints_badge]: https://img.shields.io/badge/style-lints-40C4FF.svg
[lints_link]: https://pub.dev/packages/lints
[dart_badge]: https://img.shields.io/badge/Dart-%3E%3D3.8-0175C2?logo=dart
[dart_link]: https://dart.dev
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
