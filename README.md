# Appwrite Context

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

Type-safe wrapper for Appwrite Cloud Functions context with strongly-typed request, response, headers, environment variables, and logging.

## Why? 🎯

When working with Appwrite Cloud Functions, you deal with dynamic `context` object that can be confusing and error-prone. This package provides:

- ✅ **Type Safety** - No more guessing types or runtime errors
- ✅ **IntelliSense** - Full IDE support with autocompletion
- ✅ **Convenience** - Helper methods for common HTTP responses
- ✅ **Developer Experience** - Pretty-printed logs and clear API

## Installation 💻

```sh
dart pub add widgy_appwrite_context
```

## Quick Start 🚀

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';

Future<dynamic> main(dynamic context) async {
  // Initialize type-safe context
  final ctx = AppwriteContext.initialize(context);
  
  // Access request data
  awLog('Method: ${ctx.req.method.name}');
  awLog('Path: ${ctx.req.path}');
  awLog('Query:', ctx.req.query);
  
  // Return JSON response
  return ctx.res.json({'message': 'Hello from Appwrite!'});
}
```

## Features 📦

### 1. AppwriteRequest - Type-Safe Request Data

Access all request information with proper types:

```dart
final req = ctx.req;

// Body parsing
final text = req.bodyText;           // String
final json = req.bodyJson;           // Map<String, dynamic>
final binary = req.bodyBinary;       // Uint8List

// URL components
final method = req.method;           // HttpMethod enum
final scheme = req.scheme;           // HttpScheme enum
final host = req.host;               // String
final port = req.port;               // int
final path = req.path;               // String
final url = req.url;                 // Uri

// Query parameters
final query = req.query;             // Map<String, dynamic>
final queryString = req.queryString; // String

// Headers (see next section)
final headers = req.headers;         // AppwriteHeaders
```

### 2. AppwriteHeaders - Strongly-Typed Headers

Access both Appwrite-specific and standard HTTP headers:

```dart
final headers = ctx.req.headers;

// Appwrite-specific headers
final trigger = headers.trigger;           // AppwriteTrigger enum
final userId = headers.userId;             // String?
final userJwt = headers.userJwt;          // String?
final apiKey = headers.apiKey;            // String
final executionId = headers.executionId;   // String?
final clientIp = headers.clientIp;        // String?
final countryCode = headers.countryCode;   // String?

// Standard HTTP headers
final contentType = headers.contentType;   // String?
final authorization = headers.authorization; // String?
final userAgent = headers.userAgent;       // String?
final accept = headers.accept;             // String?

// Custom headers
final customHeaders = headers.customHeaders; // Map<String, String>

// Helper methods
if (headers.isHttpTrigger) {
  awLog('Triggered via HTTP request');
}

if (headers.hasUser) {
  awLog('User ID: ${headers.userId}');
}

// Get all headers as Map
final allHeaders = headers.asMap;           // Includes nulls
final nonNullHeaders = headers.asMapNonNull; // Only set values
```

### 3. AppwriteResponse - Easy Response Building

Create responses with helper methods:

```dart
final res = ctx.res;

// JSON responses
return res.json({'status': 'success'});
return res.ok({'data': users});              // 200 OK
return res.created({'id': newId});           // 201 Created
return res.accepted({'message': 'queued'}); // 202 Accepted

// Error responses
return res.badRequest({'error': 'Invalid input'});     // 400
return res.unauthorized({'error': 'Not authenticated'}); // 401
return res.forbidden({'error': 'No permission'});       // 403
return res.notFound({'error': 'User not found'});      // 404
return res.methodNotAllowed(['POST', 'PUT']);          // 405
return res.conflict({'error': 'Email exists'});        // 409
return res.unprocessableEntity({'errors': errors});    // 422
return res.internalError({'error': 'Server error'});   // 500

// Validation helper
return res.validationError({
  'email': ['Email is required', 'Invalid format'],
  'password': ['Too short'],
});

// Other response types
return res.text('Hello World');
return res.html('<h1>Hello</h1>');
return res.empty();                    // 204 No Content
return res.redirect('https://example.com');

// File downloads
return res.downloadFile(bytes, 'data.pdf', 'application/pdf');
return res.downloadJSON({'data': 'value'}, 'data.json');

// Custom response
return res.send({
  'message': 'Custom',
}, statusCode: 418, headers: {'X-Custom': 'value'});
```

### 4. AppwriteEnvironment - Environment Variables

Type-safe access to Appwrite function environment:

```dart
final env = ctx.env;

// Function metadata
awLog('Function: ${env.functionName}');
awLog('Function ID: ${env.functionId}');
awLog('Deployment: ${env.deployment}');

// Project info
awLog('Project ID: ${env.projectId}');
awLog('Region: ${env.region}');

// API configuration
final client = Client()
  .setEndpoint(env.apiEndpoint)
  .setProject(env.projectId)
  .setKey(env.apiKey ?? '');

// All env vars as Map (with masked API key)
awLog('Environment:', env.asMap);
```

**Testing with custom environment:**

```dart
// Create test environment with mock values
final testEnv = AppwriteEnvironment(environment: {
  'APPWRITE_FUNCTION_ID': 'test-function-id',
  'APPWRITE_FUNCTION_PROJECT_ID': 'test-project-id',
  'APPWRITE_FUNCTION_NAME': 'test-function',
});

expect(testEnv.functionId, 'test-function-id');
expect(testEnv.projectId, 'test-project-id');
```

### 5. AppwriteLogger - Pretty Logging

Convenient logging with automatic formatting:

```dart
// Simple message
awLog('Function started');

// Log with data (auto pretty-print)
awLog('User data:', user);
awLog('Query params:', ctx.req.query);

// Error logging
awLogError('Failed to process:', error);

// Control pretty-printing
AppwriteLogger.prettyPrint = false;  // Disable formatting
awLog('Compact:', data);
AppwriteLogger.prettyPrint = true;   // Re-enable (default)
```

## Complete Example 📝

```dart
import 'package:widgy_appwrite_context/widgy_appwrite_context.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

Future<dynamic> main(dynamic context) async {
  final ctx = AppwriteContext.initialize(context);
  
  try {
    // Log environment info
    awLog('Function ${ctx.env.functionName} started');
    awLog('Runtime: ${ctx.env.runtimeName} ${ctx.env.runtimeVersion}');
    
    // Check authentication
    if (!ctx.req.headers.hasUser) {
      return ctx.res.unauthorized({
        'error': 'Authentication required',
      });
    }
    
    // Parse request
    final userId = ctx.req.headers.userId!;
    final action = ctx.req.query['action'] as String?;
    
    if (action == null) {
      return ctx.res.badRequest({
        'error': 'Missing action parameter',
      });
    }
    
    // Initialize Appwrite SDK
    final client = Client()
      .setEndpoint(ctx.env.apiEndpoint)
      .setProject(ctx.env.projectId)
      .setKey(ctx.req.headers.apiKey);
    
    final users = Users(client);
    
    // Process action
    switch (action) {
      case 'get':
        final user = await users.get(userId: userId);
        return ctx.res.ok({
          'user': {
            'id': user.$id,
            'email': user.email,
            'name': user.name,
          },
        });
        
      case 'delete':
        await users.delete(userId: userId);
        return ctx.res.noContent();
        
      default:
        return ctx.res.badRequest({
          'error': 'Unknown action: $action',
        });
    }
  } catch (e, stackTrace) {
    awLogError('Error:', e);
    awLogError('Stack trace:', stackTrace);
    
    return ctx.res.internalError({
      'error': 'Internal server error',
    });
  }
}
```

## API Reference 📚

### Enums

- **HttpMethod**: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`
- **HttpScheme**: `http`, `https`
- **AppwriteTrigger**: `http`, `schedule`, `event`

### Extension Methods

All enums include:
- `.value` - Get string value
- `.parse(String)` - Parse from string

---

## Running Tests 🧪

```sh
dart test
```

For coverage:

```sh
dart pub global activate coverage
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info
```

---

## License 📄

MIT License - see [LICENSE](LICENSE) for details

[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
