# Logging

Everything passed to `awLog()` shows up in the Appwrite console on the
function's execution tab.

```dart
awLog('Function started');
awLog('Body:', ctx.req.bodyJson);   // a label, then indented JSON
awLogError('Failed:', exception);
```

| Function | What it does |
| --- | --- |
| `awLog(Object? message, [Object? data])` | Writes to the log. One argument logs the message; two log a label and the data separately |
| `awLogError(Object? message, [Object? data])` | The same, to the error stream |

Maps and lists print as indented JSON, strings print as they are, `null`
becomes an empty string. If an object cannot be serialised its
`toString()` is used — logging must not bring the function down.

## Compact output

```dart
AppwriteLogger.prettyPrint = false;
```

Indentation helps a person and hinders a machine: if logs are collected
and parsed, compact records take less space and read cleanly.

## Order matters

`AppwriteLogger` is a singleton brought up by
`AppwriteContext.initialize()`. Before that call `awLog()` **silently
does nothing** — it neither fails nor writes, and you will look for
records that were never made. So the first line of the function is
always the context.

There is no need to construct the logger by hand.
