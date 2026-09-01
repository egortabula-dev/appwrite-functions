# Recipes

## A handler per function

The recommended shape: `main` only routes, and each handler is a
standalone function taking the context and the client. A handler like
that can be tested without standing up the Appwrite runtime.

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
      return ctx.res.badRequest('Missing email', details: {'email': 'required'});
    }

    final user = await Users(client).create(
      userId: ID.unique(),
      email: body['email'] as String,
      password: body['password'] as String,
    );

    return ctx.res.created({'id': user.$id, 'email': user.email});
  } catch (e, stackTrace) {
    awLogError('Create user failed:', e);
    awLogError('Stack:', stackTrace);
    return ctx.res.internalError(message: e.toString());
  }
}
```

## An authentication guard

```dart
if (!ctx.req.headers.hasUser) return ctx.res.unauthorized();

final userId = ctx.req.headers.userId!;
```

The bang is safe here precisely because it follows `hasUser`.

## Field validation

```dart
final body = ctx.req.bodyJson;
final errors = <String, List<String>>{};

if (!body.containsKey('email')) errors['email'] = ['Email is required'];
if (!body.containsKey('password')) errors['password'] = ['Password is required'];

if (errors.isNotEmpty) return ctx.res.validationError(errors);
```

Collect every error rather than answering on the first: otherwise the
user fixes the form one field per round trip.

## Tests

A context can only be made from a runtime object, so tests cover
handlers and the environment rather than `main`:

```dart
const env = AppwriteEnvironment(environment: {
  'APPWRITE_FUNCTION_ID': 'test-func',
  'APPWRITE_FUNCTION_PROJECT_ID': 'test-project',
});

expect(env.functionId, 'test-func');
```
