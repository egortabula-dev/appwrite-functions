## 0.3.0

> Note: This release has breaking changes.

 - **REFACTOR**: doc/mcp становится просто doc. ([4caeef28](https://github.com/Widgyio/packages/commit/4caeef28ecc2a0c72b2398037e299856e37689a0))
 - **FIX**(widgy_appwrite_context): опустить порог SDK до 3.8. ([a4f0ecdd](https://github.com/Widgyio/packages/commit/a4f0ecdd108e7a1c51477bd77d1dfaf79e39e2d1))
 - **DOCS**(widgy_appwrite_context): документация постранично, русская и английская. ([6a7e753a](https://github.com/Widgyio/packages/commit/6a7e753a7ff2290f8337c7e7860ed7b24c8c5062))
 - **BREAKING** **CHORE**: переименование в Widgy ([#31](https://github.com/Widgyio/packages/issues/31)). ([66fda4db](https://github.com/Widgyio/packages/commit/66fda4db29ef776cb631dbf237bcc24b082d93ed))

## [0.2.6] - 2026-04-02

### 📚 Documentation

- Update version to 0.2.4 and improve table formatting in documentation

### ⚙️ Miscellaneous Tasks

- Update MCP docs version during release process
## [0.2.5] - 2026-04-02

### 🧪 Testing

- Enhance AppwriteLogger and AppwriteEnvironment tests with additional cases

### ⚙️ Miscellaneous Tasks

- Release v0.2.5
## [0.2.4] - 2026-04-02

### 🧪 Testing

- Update coverage badge dimensions and values

### ⚙️ Miscellaneous Tasks

- Release v0.2.4
## [0.2.3] - 2026-04-02

### ⚙️ Miscellaneous Tasks

- Add PUB_TOKEN environment variable for pub publish step
- Release v0.2.3
## [0.2.2] - 2026-04-02

### ⚙️ Miscellaneous Tasks

- Update release workflow to include authentication step for pub server and adjust dependencies
- Release v0.2.2
## [0.2.1] - 2026-04-02

### 🚀 Features

- Add workflow step to publish to private pub server for stable releases

### ⚙️ Miscellaneous Tasks

- Release v0.2.1
## [0.2.0] - 2026-04-02

### 🚀 Features

- Add initial implementation of Appwrite context library with logging and request/response handling
- Update pubspec.yaml SDK version, add Appwrite function configuration and documentation
- Enhance logging functionality by adding messageToString utility for better message formatting
- Add HTTP method and scheme enums, enhance AppwriteRequest with detailed properties
- Add toString method for AppwriteRequest to improve logging and debugging
- Improve AppwriteRequest bodyJson parsing with error handling and update version in pubspec.yaml
- Enhance AppwriteRequest with safe bodyBinary parsing and update version in pubspec.yaml
- Add safe header parsing method to AppwriteRequest and update version in pubspec.yaml
- Format AppwriteRequest toString method for improved readability and update version in pubspec.yaml
- Enhance AppwriteLogger with pretty print formatting for logs and update version in pubspec.yaml
- Enhance awLog and awLogError functions with pretty-printing and update version in pubspec.yaml
- Add AppwriteTrigger enum and AppwriteHeaders model for function execution metadata; enhance AppwriteRequest with pretty-printing and update version in pubspec.yaml
- Enhance AppwriteHeaders with additional standard HTTP headers and custom header extraction; update AppwriteRequest to use AppwriteHeaders; bump version in pubspec.yaml
- Update AppwriteHeaders to handle empty header values as null; bump version in pubspec.yaml
- Add convenient getter asMap to AppwriteHeaders for easier header access; bump version in pubspec.yaml
- Enhance AppwriteHeaders with additional standard HTTP headers and non-null map representation; bump version in pubspec.yaml
- Implement AppwriteResponse class with various response methods; bump version in pubspec.yaml
- Add AppwriteEnvironment class for type-safe access to environment variables; update AppwriteContext to include environment; bump version in pubspec.yaml
- Add convenience methods asMap and asMapNonNull to AppwriteEnvironment; update version in pubspec.yaml
- Update asMapNonNull method for improved null value handling; bump version in pubspec.yaml
- Update README for clarity and add quick start guide; refactor AppwriteRequest and AppwriteLogger initialization in tests; bump version in pubspec.yaml
- Add methodNotAllowed response method and enhance AppwriteEnvironment testing; update README with custom environment examples
- Enhance internalError method to include optional error details for debugging
- Update internalError method signature to use named parameters for improved clarity
- Add CHANGELOG and update pubspec.yaml with publish and homepage information
- Add LICENSE file with MIT License terms
- Add GitHub Actions workflow for release automation and remove example function files

### 🐛 Bug Fixes

- Revert version number format in pubspec.yaml to standard format
- Update .gitignore to include example directory and ensure pubspec.lock is listed
- Update cspell configuration and enhance GitHub Actions workflow for Dart SDK 3.10.0
- Update workflow to use correct mcp-server repository path

### ⚙️ Miscellaneous Tasks

- Release v0.2.0
