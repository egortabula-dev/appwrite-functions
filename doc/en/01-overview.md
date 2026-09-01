# Overview

`widgy_appwrite_context` is a typed wrapper around the `context` object
that the Appwrite Cloud Functions runtime hands to your function.

Raw, it is `dynamic`: no editor completion, a typo in a field name shows
up on a live request, and header and body parsing gets rewritten in every
function. The package replaces it with classes that come with
completion, defaults, and compile-time checks.

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);

  if (!ctx.req.headers.hasUser) return ctx.res.unauthorized();

  return ctx.res.ok({'user': ctx.req.headers.userId});
}
```

## When to use it

When you write Cloud Functions in Dart. All the package does is give the
incoming request a shape and the outgoing response a builder.

## What it does not do

- **No dependency on `dart_appwrite`.** You create the SDK client
  yourself; the two packages are independent and versioned separately.
- **No networking or database access.** This is input parsing and output
  building, not an Appwrite client.
- **No routing.** Paths and events are yours to dispatch — see
  [Recipes](../patterns/) for what that looks like.

## Dependencies

None at runtime beyond `dart:io`, `dart:convert` and `dart:typed_data`.
For development: `test`, `mocktail`, `very_good_analysis`.
