# Installation

## The dependency form: legacy only

Appwrite's Dart runtime uses an outdated pubspec parser (2.3.0). It does
**not** understand the modern shorthand for a private registry, and the
function build fails with

```
type 'Null' is not a subtype of type 'String'
```

The message says nothing about the cause, so memorise the form.

**Correct:**

```yaml
dependencies:
  widgy_appwrite_context:
    hosted:
      name: widgy_appwrite_context
      url: https://pub.widgy.io
    version: ^0.2.6
```

**Breaks the build:**

```yaml
dependencies:
  widgy_appwrite_context:
    hosted: https://pub.widgy.io
```

The only difference is that `hosted` is a string in the second form
rather than an object. Modern `pub` accepts both; Appwrite's parser
accepts the first only.

## Registry token

Widgy packages are installed with a token. In the Appwrite console, set a
secret variable `WIDGY_PUB_TOKEN` to your token, and register it in the
function's build command:

```
dart pub token add https://pub.widgy.io --env-var WIDGY_PUB_TOKEN && dart pub get
```

Without the first command `dart pub get` gets a 401 and the build stops.

## One import

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';
```

It brings everything: models, enums and logging.
