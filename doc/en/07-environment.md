# Environment

`AppwriteEnvironment` gives typed access to the function's environment
variables. It reads `Platform.environment` by default but accepts a map
of its own — that is what tests are built on.

```dart
const AppwriteEnvironment({Map<String, String>? environment});
```

| Property | Variable | Available | What it is |
| --- | --- | --- | --- |
| `apiEndpoint` | `APPWRITE_FUNCTION_API_ENDPOINT` | build and run | API endpoint |
| `appwriteVersion` | `APPWRITE_VERSION` | build and run | Appwrite version |
| `region` | `APPWRITE_REGION` | build and run | Region |
| `apiKey` | `APPWRITE_FUNCTION_API_KEY` | **build only** | The function key |
| `functionId` | `APPWRITE_FUNCTION_ID` | build and run | Function id |
| `functionName` | `APPWRITE_FUNCTION_NAME` | build and run | Function name |
| `deployment` | `APPWRITE_FUNCTION_DEPLOYMENT` | build and run | Deployment id |
| `projectId` | `APPWRITE_FUNCTION_PROJECT_ID` | build and run | Project |
| `runtimeName` | `APPWRITE_FUNCTION_RUNTIME_NAME` | build and run | Runtime |
| `runtimeVersion` | `APPWRITE_FUNCTION_RUNTIME_VERSION` | build and run | Runtime version |

`asMap` returns everything with the **key masked** as `***`;
`asMapNonNull` returns only what is set. The masking is not cosmetic —
an environment map most often ends up in a log.

## The build key and the runtime key are different

`env.apiKey` exists only during the build. In a running function it is
`null`, and a client built with it gets a 401 on its first call.

At runtime the key arrives in the `x-appwrite-key` header:

```dart
final client = Client()
    .setEndpoint(ctx.env.apiEndpoint)
    .setProject(ctx.env.projectId)
    .setKey(ctx.req.headers.apiKey);  // not ctx.env.apiKey
```

This one survives review: the code compiles, tests pass, the function
deploys — and it fails only on a real request.

## Substituting in tests

```dart
const env = AppwriteEnvironment(environment: {
  'APPWRITE_FUNCTION_ID': 'test-func',
  'APPWRITE_FUNCTION_PROJECT_ID': 'test-project',
  'APPWRITE_FUNCTION_API_ENDPOINT': 'https://test.appwrite.io/v1',
});

expect(env.functionId, 'test-func');
```
