# appwrite-functions

[![CI](https://github.com/egortabula-dev/appwrite-functions/actions/workflows/ci.yml/badge.svg)](https://github.com/egortabula-dev/appwrite-functions/actions/workflows/ci.yml)
[![Dart](https://img.shields.io/badge/Dart-%3E%3D3.8-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

> Dart tooling for Appwrite Cloud Functions.

Writing an Appwrite function in Dart means starting from an untyped context
object and a bare handler. These packages fill the gap between that and the
code you actually wanted to write.

## Packages

| Package | Description |
|---------|-------------|
| [appwrite_functions_context](packages/appwrite_functions_context) | Typed request, headers, response builders and environment |

Planned, in this order:

- **router** — method and path to handler, path parameters, `405` and `404`
  answered for you instead of forgotten
- **spec + generator** — describe a function's contract once, generate a
  client that cannot drift from it

Each is published separately. The runtime packages stay dependency-free
because Appwrite resolves dev dependencies too when it builds a function: a
code generator living in the same package would be downloaded on every build
of every function.

## Runtimes

Dart from **3.8**. Appwrite ships `dart-3.0` through `dart-3.11`, and the
older runtimes stay in use for years, so the floor is deliberately low and CI
tests on it rather than only on the newest stable.

## Development

```sh
dart pub get
dart analyze --fatal-infos
dart test
```

A pub workspace, no melos: melos would raise the workspace floor to Dart 3.9
and these packages need to stay loadable below that. Versions, changelogs and
tags come from release-please, driven by conventional commits.

## License

MIT — see [LICENSE](LICENSE).
