# Gotchas

Collected from real breakages. They have one thing in common: the code
builds and deploys, and fails later.

## 1. The shorthand `hosted` form breaks the build

Appwrite's pubspec parser is old and understands only the expanded form.
The error — `type 'Null' is not a subtype of type 'String'` — says
nothing about the cause. Details in [Installation](../installation/).

## 2. `env.apiKey` is empty in a running function

It exists only during the build. At runtime the key arrives in a header:
`ctx.req.headers.apiKey`. A client built with `env.apiKey` gets a 401 —
and only on a real request, never in tests.

## 3. `awLog()` before `initialize()` is silent

The logger is brought up by creating the context. Calling it earlier is
not an error but a no-op: you will hunt for records that were never
written. The first line of the function is always
`AppwriteContext.initialize(context)`.

## 4. Parsing never throws

A missing method becomes `GET`, a scheme `HTTPS`, a trigger `http`, a
port zero, strings empty, maps empty. Convenient — and it means **an
empty value is indistinguishable from a missing one**. Where the
difference matters to your logic, check explicitly: `hasBodyJson`,
`hasQuery`, `hasUser`.

## 5. The response leaves through the runtime, not the package

`ctx.res` methods delegate to the real `context.res`. The package does
not intercept the HTTP response and cannot replace it — it provides
types and ready-made shapes, nothing more.

## 6. `AppwriteResponseResult` is `dynamic`

The Appwrite runtime contract requires it. The alias exists to make
signatures readable; there is no type checking behind it.
