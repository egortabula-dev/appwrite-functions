// The deprecated logging API is tested on purpose.
// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:appwrite_functions_context/src/mixins/mixins.dart';
import 'package:appwrite_functions_context/src/utils.dart';
import 'package:appwrite_functions_context/appwrite_functions_context.dart';

void main() {
  group('AppwriteContext', () {
    test('handle wraps the dynamic context', () async {
      final ctx = await AppwriteContext.handle(_MockContext(), (ctx) => ctx);

      expect(ctx.req.host, 'example.com');
      expect(ctx.res, isNotNull);
    });

    test('handle returns the handler result and propagates errors', () async {
      expect(await AppwriteContext.handle(_MockContext(), (ctx) => 42), 42);
      await expectLater(
        AppwriteContext.handle<void>(
          _MockContext(),
          (ctx) => throw StateError('boom'),
        ),
        throwsStateError,
      );
    });

    test('handle does not touch the global fallback', () async {
      final raw = _MockContext();
      await AppwriteContext.handle(raw, (ctx) {});

      awLog('outside');
      awLogError('outside');

      expect(raw.logMessages, isEmpty);
      expect(raw.errorMessages, isEmpty);
    });
  });

  group('AppwriteLogger', () {
    test('can log messages', () {
      final mockContext = _MockContext();
      AppwriteLogger(mockContext).log('test message');
      expect(mockContext.logMessages, ['test message']);
    });

    test('can log errors', () {
      final mockContext = _MockContext();
      AppwriteLogger(mockContext).error('test error');
      expect(mockContext.errorMessages, ['test error']);
    });

    test('logs label and data separately', () {
      final mockContext = _MockContext();
      AppwriteLogger(mockContext)
        ..log('label:', 'data')
        ..error('label:', 'error-data');
      expect(mockContext.logMessages, ['label:', 'data']);
      expect(mockContext.errorMessages, ['label:', 'error-data']);
    });

    test('formats null message as empty string', () {
      final mockContext = _MockContext();
      AppwriteLogger(mockContext).log(null);
      expect(mockContext.logMessages, ['']);
    });

    test('formats non-string message using toString', () {
      final mockContext = _MockContext();
      AppwriteLogger(mockContext).log(42);
      expect(mockContext.logMessages, ['42']);
    });

    test('pretty prints maps when prettyPrint is enabled', () {
      AppwriteLogger.prettyPrint = true;
      final mockContext = _MockContext();
      AppwriteLogger(mockContext).log({'key': 'value'});
      expect(mockContext.logMessages.last, contains('"key"'));
      expect(mockContext.logMessages.last, contains('"value"'));
    });

    test('compact format when prettyPrint is disabled', () {
      AppwriteLogger.prettyPrint = false;
      final mockContext = _MockContext();
      AppwriteLogger(mockContext).log({'key': 'value'});
      expect(mockContext.logMessages.last, contains('key'));
      AppwriteLogger.prettyPrint = true; // Reset
    });

    test('ignores a null context', () {
      expect(() => AppwriteLogger(null).log('x', 'y'), returnsNormally);
    });
  });

  group('awLog (deprecated)', () {
    test('logs single message', () async {
      final mockContext = _MockContext();
      await AppwriteContext.handle(mockContext, (ctx) => awLog('hello'));
      expect(mockContext.logMessages, ['hello']);
    });

    test('logs label and data separately', () async {
      final mockContext = _MockContext();
      await AppwriteContext.handle(
        mockContext,
        (ctx) => awLog('label:', 'data'),
      );
      expect(mockContext.logMessages, ['label:', 'data']);
    });
  });

  group('awLogError (deprecated)', () {
    test('logs single error', () async {
      final mockContext = _MockContext();
      await AppwriteContext.handle(mockContext, (ctx) => awLogError('fail'));
      expect(mockContext.errorMessages, ['fail']);
    });

    test('logs label and data separately', () async {
      final mockContext = _MockContext();
      await AppwriteContext.handle(
        mockContext,
        (ctx) => awLogError('label:', 'error-data'),
      );
      expect(mockContext.errorMessages, ['label:', 'error-data']);
    });
  });

  group('concurrent requests', () {
    test('awLog inside handle stays with its own request', () async {
      final first = _MockContext();
      final second = _MockContext();

      await Future.wait([
        AppwriteContext.handle(first, (ctx) async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          awLog('a');
          awLogError('a-error');
        }),
        AppwriteContext.handle(second, (ctx) async {
          awLog('b');
          awLogError('b-error');
        }),
      ]);

      expect(first.logMessages, ['a']);
      expect(first.errorMessages, ['a-error']);
      expect(second.logMessages, ['b']);
      expect(second.errorMessages, ['b-error']);
    });

    test('ctx.log stays with its own request without a zone', () async {
      final first = _MockContext();
      final second = _MockContext();
      final firstCtx = await AppwriteContext.handle(first, (ctx) => ctx);
      final secondCtx = await AppwriteContext.handle(second, (ctx) => ctx);

      Future<void> run(AppwriteContext ctx, String line, Duration delay) async {
        await Future<void>.delayed(delay);
        ctx.log(line);
        ctx.error('$line-error');
      }

      await Future.wait([
        run(firstCtx, 'a', const Duration(milliseconds: 20)),
        run(secondCtx, 'b', Duration.zero),
      ]);

      expect(first.logMessages, ['a']);
      expect(first.errorMessages, ['a-error']);
      expect(second.logMessages, ['b']);
      expect(second.errorMessages, ['b-error']);
    });

    test('ctx.log and awLog format two arguments identically', () async {
      final viaCtx = _MockContext();
      final viaAwLog = _MockContext();
      const data = {
        'key': 'value',
        'list': [1, 2],
      };

      await AppwriteContext.handle(viaCtx, (ctx) {
        ctx
          ..log('label:', data)
          ..error('label:', data);
      });
      await AppwriteContext.handle(viaAwLog, (ctx) {
        awLog('label:', data);
        awLogError('label:', data);
      });

      expect(viaCtx.logMessages, hasLength(2));
      expect(viaCtx.logMessages.first, 'label:');
      expect(viaCtx.logMessages.last, contains('\n  "key": "value"'));
      expect(viaAwLog.logMessages, viaCtx.logMessages);
      expect(viaCtx.errorMessages, viaCtx.logMessages);
      expect(viaAwLog.errorMessages, viaCtx.errorMessages);
    });
  });

  group('deprecated global fallback', () {
    test('AppwriteContext.initialize wraps the dynamic context', () {
      final ctx = AppwriteContext.initialize(_MockContext());
      expect(ctx.req.host, 'example.com');
    });

    test('awLog writes to the last initialized context', () {
      final first = _MockContext();
      final second = _MockContext();

      AppwriteContext.initialize(first);
      AppwriteContext.initialize(second);
      awLog('line');
      awLogError('error');

      expect(first.logMessages, isEmpty);
      expect(first.errorMessages, isEmpty);
      expect(second.logMessages, ['line']);
      expect(second.errorMessages, ['error']);
    });

    test('AppwriteLogger.initialize sets the fallback', () {
      final mockContext = _MockContext();
      AppwriteLogger.initialize(mockContext);
      awLog('label:', 'data');
      awLogError('fail');
      expect(mockContext.logMessages, ['label:', 'data']);
      expect(mockContext.errorMessages, ['fail']);
    });

    test('ctx.log from initialize stays with its own request', () {
      final first = _MockContext();
      final second = _MockContext();

      final firstCtx = AppwriteContext.initialize(first);
      AppwriteContext.initialize(second);
      firstCtx.log('a');

      expect(first.logMessages, ['a']);
      expect(second.logMessages, isEmpty);
    });

    test('handle wins over the fallback', () async {
      final global = _MockContext();
      final scoped = _MockContext();

      AppwriteContext.initialize(global);
      await AppwriteContext.handle(scoped, (ctx) => awLog('scoped'));

      expect(scoped.logMessages, ['scoped']);
      expect(global.logMessages, isEmpty);
    });
  });

  group('AppwriteEnvironment', () {
    test('can use custom environment for testing', () {
      const testEnv = AppwriteEnvironment(
        environment: {
          'APPWRITE_FUNCTION_ID': 'test-function-123',
          'APPWRITE_FUNCTION_PROJECT_ID': 'test-project-456',
          'APPWRITE_FUNCTION_NAME': 'test-function',
          'APPWRITE_REGION': 'test-region',
        },
      );

      expect(testEnv.functionId, 'test-function-123');
      expect(testEnv.projectId, 'test-project-456');
      expect(testEnv.functionName, 'test-function');
      expect(testEnv.region, 'test-region');
    });

    test('returns empty string for missing env vars', () {
      const testEnv = AppwriteEnvironment(environment: {});

      expect(testEnv.functionId, '');
      expect(testEnv.projectId, '');
      expect(testEnv.apiEndpoint, '');
      expect(testEnv.appwriteVersion, '');
      expect(testEnv.deployment, '');
      expect(testEnv.runtimeName, '');
      expect(testEnv.runtimeVersion, '');
      expect(testEnv.functionName, '');
    });

    test('returns null for missing apiKey', () {
      const testEnv = AppwriteEnvironment(environment: {});
      expect(testEnv.apiKey, isNull);
    });

    test('masks API key in toMap', () {
      const testEnv = AppwriteEnvironment(
        environment: {'APPWRITE_FUNCTION_API_KEY': 'secret-key-123'},
      );

      final map = testEnv.toMap();
      expect(map['apiKey'], '***');
    });

    test('asMap returns same as toMap', () {
      const testEnv = AppwriteEnvironment(environment: {});
      expect(testEnv.asMap, testEnv.toMap());
    });

    test('asMapNonNull excludes null values', () {
      const testEnv = AppwriteEnvironment(environment: {});
      final map = testEnv.asMapNonNull;
      expect(map.values.where((v) => v == null), isEmpty);
    });

    test('all fields populated', () {
      const testEnv = AppwriteEnvironment(
        environment: {
          'APPWRITE_FUNCTION_API_ENDPOINT': 'https://cloud.appwrite.io/v1',
          'APPWRITE_VERSION': '1.4.0',
          'APPWRITE_REGION': 'default',
          'APPWRITE_FUNCTION_API_KEY': 'key-123',
          'APPWRITE_FUNCTION_ID': 'func-id',
          'APPWRITE_FUNCTION_NAME': 'my-func',
          'APPWRITE_FUNCTION_DEPLOYMENT': 'deploy-id',
          'APPWRITE_FUNCTION_PROJECT_ID': 'proj-id',
          'APPWRITE_FUNCTION_RUNTIME_NAME': 'dart-3.0',
          'APPWRITE_FUNCTION_RUNTIME_VERSION': '3.0.0',
        },
      );

      expect(testEnv.apiEndpoint, 'https://cloud.appwrite.io/v1');
      expect(testEnv.appwriteVersion, '1.4.0');
      expect(testEnv.region, 'default');
      expect(testEnv.apiKey, 'key-123');
      expect(testEnv.functionId, 'func-id');
      expect(testEnv.functionName, 'my-func');
      expect(testEnv.deployment, 'deploy-id');
      expect(testEnv.projectId, 'proj-id');
      expect(testEnv.runtimeName, 'dart-3.0');
      expect(testEnv.runtimeVersion, '3.0.0');
    });
  });

  group('AppwriteTrigger', () {
    test('value returns uppercase', () {
      expect(AppwriteTrigger.http.value, 'HTTP');
      expect(AppwriteTrigger.schedule.value, 'SCHEDULE');
      expect(AppwriteTrigger.event.value, 'EVENT');
    });

    test('parse returns correct trigger', () {
      expect(AppwriteTriggerExtension.parse('http'), AppwriteTrigger.http);
      expect(
        AppwriteTriggerExtension.parse('schedule'),
        AppwriteTrigger.schedule,
      );
      expect(AppwriteTriggerExtension.parse('event'), AppwriteTrigger.event);
    });

    test('parse is case-insensitive', () {
      expect(AppwriteTriggerExtension.parse('HTTP'), AppwriteTrigger.http);
      expect(
        AppwriteTriggerExtension.parse('Schedule'),
        AppwriteTrigger.schedule,
      );
      expect(AppwriteTriggerExtension.parse('EVENT'), AppwriteTrigger.event);
    });

    test('parse returns http for null', () {
      expect(AppwriteTriggerExtension.parse(null), AppwriteTrigger.http);
    });

    test('parse returns http for invalid value', () {
      expect(AppwriteTriggerExtension.parse('unknown'), AppwriteTrigger.http);
    });
  });

  group('HttpMethod', () {
    test('value returns uppercase', () {
      expect(HttpMethod.get.value, 'GET');
      expect(HttpMethod.post.value, 'POST');
      expect(HttpMethod.put.value, 'PUT');
      expect(HttpMethod.patch.value, 'PATCH');
      expect(HttpMethod.delete.value, 'DELETE');
      expect(HttpMethod.options.value, 'OPTIONS');
      expect(HttpMethod.head.value, 'HEAD');
    });

    test('parse returns correct method', () {
      expect(HttpMethodExtension.parse('GET'), HttpMethod.get);
      expect(HttpMethodExtension.parse('POST'), HttpMethod.post);
      expect(HttpMethodExtension.parse('PUT'), HttpMethod.put);
      expect(HttpMethodExtension.parse('PATCH'), HttpMethod.patch);
      expect(HttpMethodExtension.parse('DELETE'), HttpMethod.delete);
      expect(HttpMethodExtension.parse('OPTIONS'), HttpMethod.options);
      expect(HttpMethodExtension.parse('HEAD'), HttpMethod.head);
    });

    test('parse is case-insensitive', () {
      expect(HttpMethodExtension.parse('get'), HttpMethod.get);
      expect(HttpMethodExtension.parse('Post'), HttpMethod.post);
    });

    test('parse returns get for null', () {
      expect(HttpMethodExtension.parse(null), HttpMethod.get);
    });

    test('parse returns get for unknown method', () {
      expect(HttpMethodExtension.parse('UNKNOWN'), HttpMethod.get);
    });
  });

  group('HttpScheme', () {
    test('value returns correct string', () {
      expect(HttpScheme.http.value, 'http');
      expect(HttpScheme.https.value, 'https');
    });

    test('isSecure returns correct value', () {
      expect(HttpScheme.http.isSecure, isFalse);
      expect(HttpScheme.https.isSecure, isTrue);
    });

    test('parse returns http for "http"', () {
      expect(HttpSchemeExtension.parse('http'), HttpScheme.http);
    });

    test('parse returns https for "https"', () {
      expect(HttpSchemeExtension.parse('https'), HttpScheme.https);
    });

    test('parse is case-insensitive', () {
      expect(HttpSchemeExtension.parse('HTTP'), HttpScheme.http);
      expect(HttpSchemeExtension.parse('HTTPS'), HttpScheme.https);
    });

    test('parse defaults to https for null', () {
      expect(HttpSchemeExtension.parse(null), HttpScheme.https);
    });

    test('parse defaults to https for unknown', () {
      expect(HttpSchemeExtension.parse('ftp'), HttpScheme.https);
    });
  });

  group('AppwriteHeaders', () {
    test('parses appwrite headers correctly', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-trigger': 'http',
        'x-appwrite-event': 'users.*.create',
        'x-appwrite-key': 'test-api-key',
        'x-appwrite-user-id': 'user-123',
        'x-appwrite-user-jwt': 'jwt-token',
        'x-appwrite-country-code': 'US',
        'x-appwrite-continent-code': 'NA',
        'x-appwrite-continent-eu': 'false',
        'x-appwrite-client-ip': '192.168.1.1',
        'x-appwrite-execution-id': 'exec-123',
      });

      expect(headers.trigger, AppwriteTrigger.http);
      expect(headers.event, 'users.*.create');
      expect(headers.apiKey, 'test-api-key');
      expect(headers.userId, 'user-123');
      expect(headers.userJwt, 'jwt-token');
      expect(headers.countryCode, 'US');
      expect(headers.continentCode, 'NA');
      expect(headers.isInEU, isFalse);
      expect(headers.clientIp, '192.168.1.1');
      expect(headers.executionId, 'exec-123');
    });

    test('sets isInEU to true', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-continent-eu': 'true',
      });
      expect(headers.isInEU, isTrue);
    });

    test('parses standard HTTP headers', () {
      final headers = AppwriteHeaders.fromHeaders({
        'authorization': 'Bearer token',
        'content-type': 'application/json',
        'content-length': '256',
        'accept': 'application/json',
        'host': 'example.com',
        'cookie': 'sessionid=abc',
        'cache-control': 'no-cache',
        'forwarded': 'for=127.0.0.1',
        'user-agent': 'TestAgent/1.0',
        'referer': 'https://example.com',
        'origin': 'https://example.com',
      });

      expect(headers.authorization, 'Bearer token');
      expect(headers.contentType, 'application/json');
      expect(headers.contentLength, 256);
      expect(headers.accept, 'application/json');
      expect(headers.host, 'example.com');
      expect(headers.cookie, 'sessionid=abc');
      expect(headers.cacheControl, 'no-cache');
      expect(headers.forwarded, 'for=127.0.0.1');
      expect(headers.userAgent, 'TestAgent/1.0');
      expect(headers.referer, 'https://example.com');
      expect(headers.origin, 'https://example.com');
    });

    test('returns null for empty optional headers', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-event': '',
        'x-appwrite-user-id': '',
        'x-appwrite-user-jwt': '',
        'x-appwrite-country-code': '',
        'x-appwrite-continent-code': '',
        'authorization': '',
        'content-type': '',
        'accept': '',
        'host': '',
        'cookie': '',
        'cache-control': '',
        'forwarded': '',
        'user-agent': '',
        'referer': '',
        'origin': '',
      });

      expect(headers.event, isNull);
      expect(headers.userId, isNull);
      expect(headers.userJwt, isNull);
      expect(headers.countryCode, isNull);
      expect(headers.continentCode, isNull);
      expect(headers.authorization, isNull);
      expect(headers.contentType, isNull);
      expect(headers.accept, isNull);
      expect(headers.host, isNull);
      expect(headers.cookie, isNull);
      expect(headers.cacheControl, isNull);
      expect(headers.forwarded, isNull);
      expect(headers.userAgent, isNull);
      expect(headers.referer, isNull);
      expect(headers.origin, isNull);
    });

    test('returns 0 for invalid content-length', () {
      final headers = AppwriteHeaders.fromHeaders({
        'content-length': 'not-a-number',
      });
      expect(headers.contentLength, 0);
    });

    test('extracts custom headers', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-trigger': 'http',
        'content-type': 'text/plain',
        'x-custom-header': 'custom-value',
        'x-another': 'another-value',
      });

      expect(headers.customHeaders, {
        'x-custom-header': 'custom-value',
        'x-another': 'another-value',
      });
      expect(headers.hasCustomHeaders, isTrue);
    });

    test('hasCustomHeaders returns false when no custom headers', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-trigger': 'http',
      });
      expect(headers.hasCustomHeaders, isFalse);
    });

    test('convenience boolean getters work correctly', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-trigger': 'http',
        'x-appwrite-user-id': 'user-123',
        'x-appwrite-user-jwt': 'jwt-token',
        'x-appwrite-event': 'users.*.create',
        'authorization': 'Bearer token',
        'content-type': 'application/json',
      });

      expect(headers.isHttpTrigger, isTrue);
      expect(headers.isScheduleTrigger, isFalse);
      expect(headers.isEventTrigger, isFalse);
      expect(headers.hasUser, isTrue);
      expect(headers.hasUserJwt, isTrue);
      expect(headers.hasEvent, isTrue);
      expect(headers.hasAuthorization, isTrue);
      expect(headers.hasContentType, isTrue);
    });

    test('schedule trigger getter', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-trigger': 'schedule',
      });
      expect(headers.isScheduleTrigger, isTrue);
      expect(headers.isHttpTrigger, isFalse);
    });

    test('event trigger getter', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-trigger': 'event',
      });
      expect(headers.isEventTrigger, isTrue);
      expect(headers.isHttpTrigger, isFalse);
    });

    test('toMap returns all fields', () {
      final headers = AppwriteHeaders.fromHeaders({
        'x-appwrite-trigger': 'http',
        'x-appwrite-execution-id': 'exec-1',
        'x-appwrite-client-ip': '10.0.0.1',
      });

      final map = headers.toMap();
      expect(map, containsPair('trigger', 'HTTP'));
      expect(map, containsPair('executionId', 'exec-1'));
      expect(map, containsPair('clientIp', '10.0.0.1'));
    });

    test('asMap returns same as toMap', () {
      final headers = AppwriteHeaders.fromHeaders({});
      expect(headers.asMap, headers.toMap());
    });

    test('asMapNonNull excludes null values', () {
      final headers = AppwriteHeaders.fromHeaders({});
      final map = headers.asMapNonNull;
      expect(map.values.where((v) => v == null), isEmpty);
    });
  });

  group('AppwriteRequest', () {
    test('parses basic request from context', () {
      final mockContext = _MockContext();
      final req = AppwriteRequest.fromContext(mockContext);

      expect(req.bodyText, '');
      expect(req.bodyJson, isEmpty);
      expect(req.bodyBinary, isEmpty);
      expect(req.method, HttpMethod.get);
      expect(req.scheme, HttpScheme.https);
      expect(req.host, 'example.com');
      expect(req.port, 443);
      expect(req.path, '/');
      expect(req.queryString, '');
      expect(req.query, isEmpty);
    });

    test('parses request with body', () {
      final mockContext = _MockContext(
        bodyText: '{"key": "value"}',
        bodyJson: {'key': 'value'},
        bodyBinary: [104, 101, 108, 108, 111],
      );
      final req = AppwriteRequest.fromContext(mockContext);

      expect(req.bodyText, '{"key": "value"}');
      expect(req.bodyJson, {'key': 'value'});
      expect(req.bodyBinary, isNotEmpty);
      expect(req.hasBodyText, isTrue);
      expect(req.hasBodyJson, isTrue);
      expect(req.hasBodyBinary, isTrue);
    });

    test('parses request with query', () {
      final mockContext = _MockContext(
        queryString: 'limit=10&offset=0',
        query: {'limit': '10', 'offset': '0'},
      );
      final req = AppwriteRequest.fromContext(mockContext);

      expect(req.queryString, 'limit=10&offset=0');
      expect(req.query, {'limit': '10', 'offset': '0'});
      expect(req.hasQuery, isTrue);
    });

    test('parses URL correctly', () {
      final mockContext = _MockContext(
        url: 'https://example.com:8000/v1/hooks?limit=12',
      );
      final req = AppwriteRequest.fromContext(mockContext);

      expect(req.url, isA<Uri>());
      expect(req.urlString, 'https://example.com:8000/v1/hooks?limit=12');
    });

    test('handles null URL', () {
      final mockContext = _MockContext();
      final req = AppwriteRequest.fromContext(mockContext);
      expect(req.url, isA<Uri>());
    });

    test('handles empty URL', () {
      final mockContext = _MockContext(url: '');
      final req = AppwriteRequest.fromContext(mockContext);
      expect(req.url, isA<Uri>());
    });

    test('parses different HTTP methods', () {
      for (final method in ['POST', 'PUT', 'DELETE', 'PATCH']) {
        final mockContext = _MockContext(method: method);
        final req = AppwriteRequest.fromContext(mockContext);
        expect(req.method.value, method);
      }
    });

    test('parses HTTP scheme', () {
      final mockContext = _MockContext(scheme: 'http');
      final req = AppwriteRequest.fromContext(mockContext);
      expect(req.scheme, HttpScheme.http);
      expect(req.scheme.isSecure, isFalse);
    });

    test('parses port as string', () {
      final mockContext = _MockContext(port: '8080');
      final req = AppwriteRequest.fromContext(mockContext);
      expect(req.port, 8080);
    });

    test('handles null context gracefully', () {
      final req = AppwriteRequest.fromContext(null);
      expect(req.bodyText, '');
      expect(req.bodyJson, isEmpty);
      expect(req.bodyBinary, isEmpty);
      expect(req.method, HttpMethod.get);
      expect(req.scheme, HttpScheme.https);
      expect(req.host, '');
      expect(req.port, 0);
      expect(req.path, '');
    });

    test('boolean helpers for empty request', () {
      final mockContext = _MockContext();
      final req = AppwriteRequest.fromContext(mockContext);

      expect(req.hasBodyText, isFalse);
      expect(req.hasBodyJson, isFalse);
      expect(req.hasBodyBinary, isFalse);
      expect(req.hasQuery, isFalse);
    });

    test('toMap returns correct structure', () {
      final mockContext = _MockContext();
      final req = AppwriteRequest.fromContext(mockContext);
      final map = req.toMap();

      expect(map, containsPair('method', 'GET'));
      expect(map, containsPair('scheme', 'https'));
      expect(map, containsPair('host', 'example.com'));
      expect(map, containsPair('port', 443));
      expect(map, containsPair('path', '/'));
      expect(map, contains('url'));
      expect(map, contains('headers'));
    });
  });

  group('AppwriteResponse', () {
    test('empty returns null', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      expect(res.empty(), isNull);
    });

    test('json sends data with status code', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      final result = res.json({'key': 'value'});
      expect(result, {'key': 'value'});
      expect(mockContext.res.lastStatusCode, 200);
    });

    test('json sends custom status code', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      res.json({'key': 'value'}, statusCode: 201);
      expect(mockContext.res.lastStatusCode, 201);
    });

    test('text sends string response', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      final result = res.text('hello');
      expect(result, 'hello');
      expect(mockContext.res.lastStatusCode, 200);
    });

    test('text sends custom status code', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      res.text('hello', statusCode: 201);
      expect(mockContext.res.lastStatusCode, 201);
    });

    test('text sends headers', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      res.text('hello', headers: {'X-Custom': 'val'});
      expect(mockContext.res.lastHeaders, {'X-Custom': 'val'});
    });

    test('html sends with content-type header', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      final result = res.html('<h1>Hello</h1>');
      expect(result, '<h1>Hello</h1>');
      expect(mockContext.res.lastHeaders, {
        'Content-Type': 'text/html; charset=utf-8',
      });
    });

    test('binary sends Uint8List', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      final data = Uint8List.fromList([1, 2, 3]);
      final result = res.binary(data);
      expect(result, data);
      expect(mockContext.res.lastStatusCode, 200);
    });

    test('binary sends headers', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      final data = Uint8List.fromList([1, 2, 3]);
      res.binary(data, headers: {'Content-Type': 'image/png'});
      expect(mockContext.res.lastHeaders, {'Content-Type': 'image/png'});
    });

    test('redirect sends url and status', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      final result = res.redirect('https://example.com');
      expect(result, 'https://example.com');
      expect(mockContext.res.lastStatusCode, 302);
    });

    test('redirect with custom status code', () {
      final mockContext = _MockContext();
      final res = AppwriteResponse.fromContext(mockContext);
      res.redirect('https://example.com', statusCode: 301);
      expect(mockContext.res.lastStatusCode, 301);
    });

    group('success helpers', () {
      test('ok sends 200', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.ok({'data': 'ok'});
        expect(result, {'data': 'ok'});
        expect(mockContext.res.lastStatusCode, 200);
      });

      test('created sends 201', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        res.created({'id': '123'});
        expect(mockContext.res.lastStatusCode, 201);
      });

      test('accepted sends 202 with default message', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.accepted() as Map<String, dynamic>;
        expect(result['message'], 'Accepted');
        expect(mockContext.res.lastStatusCode, 202);
      });

      test('accepted sends 202 with custom data', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.accepted({'jobId': '123'}) as Map<String, dynamic>;
        expect(result['jobId'], '123');
      });

      test('noContent calls empty', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        expect(res.noContent(), isNull);
      });

      test('success sends standard format', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.success('Done') as Map<String, dynamic>;
        expect(result['success'], isTrue);
        expect(result['message'], 'Done');
      });

      test('success with data', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.success('Created', data: {'id': '1'}, statusCode: 201)
                as Map<String, dynamic>;
        expect(result['data'], {'id': '1'});
        expect(mockContext.res.lastStatusCode, 201);
      });
    });

    group('error helpers', () {
      test('badRequest sends 400', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.badRequest('Invalid input') as Map<String, dynamic>;
        expect(result['error'], 'Bad Request');
        expect(result['message'], 'Invalid input');
        expect(mockContext.res.lastStatusCode, 400);
      });

      test('badRequest with details', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.badRequest('Validation failed', details: {'email': 'required'})
                as Map<String, dynamic>;
        expect(result['details'], {'email': 'required'});
      });

      test('unauthorized sends 401 with default message', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.unauthorized() as Map<String, dynamic>;
        expect(result['error'], 'Unauthorized');
        expect(result['message'], 'Authentication required');
        expect(mockContext.res.lastStatusCode, 401);
      });

      test('unauthorized with custom message', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.unauthorized('Token expired') as Map<String, dynamic>;
        expect(result['message'], 'Token expired');
      });

      test('forbidden sends 403', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.forbidden() as Map<String, dynamic>;
        expect(result['error'], 'Forbidden');
        expect(result['message'], 'Access forbidden');
        expect(mockContext.res.lastStatusCode, 403);
      });

      test('forbidden with custom message', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.forbidden('No access') as Map<String, dynamic>;
        expect(result['message'], 'No access');
      });

      test('notFound sends 404', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.notFound() as Map<String, dynamic>;
        expect(result['error'], 'Not Found');
        expect(result['message'], 'Resource not found');
        expect(mockContext.res.lastStatusCode, 404);
      });

      test('notFound with resource name', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.notFound('User') as Map<String, dynamic>;
        expect(result['message'], 'User not found');
      });

      test('methodNotAllowed sends 405', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.methodNotAllowed() as Map<String, dynamic>;
        expect(result['error'], 'Method Not Allowed');
        expect(result['message'], 'Method not allowed');
        expect(mockContext.res.lastStatusCode, 405);
      });

      test('methodNotAllowed with allowed methods', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.methodNotAllowed(['POST', 'PUT']) as Map<String, dynamic>;
        expect(result['message'], 'This endpoint only supports: POST, PUT');
      });

      test('conflict sends 409', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.conflict('Duplicate entry') as Map<String, dynamic>;
        expect(result['error'], 'Conflict');
        expect(result['message'], 'Duplicate entry');
        expect(mockContext.res.lastStatusCode, 409);
      });

      test('unprocessableEntity sends 422', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.unprocessableEntity('Invalid data') as Map<String, dynamic>;
        expect(result['error'], 'Unprocessable Entity');
        expect(mockContext.res.lastStatusCode, 422);
      });

      test('unprocessableEntity with errors', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.unprocessableEntity('Validation', errors: {'email': 'invalid'})
                as Map<String, dynamic>;
        expect(result['errors'], {'email': 'invalid'});
      });

      test('internalError sends 500', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.internalError() as Map<String, dynamic>;
        expect(result['error'], 'Internal Server Error');
        expect(result['message'], 'Internal server error');
        expect(mockContext.res.lastStatusCode, 500);
      });

      test('internalError with custom message and data', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.internalError(message: 'DB failed', data: {'query': 'SELECT *'})
                as Map<String, dynamic>;
        expect(result['message'], 'DB failed');
        expect(result['data'], {'query': 'SELECT *'});
      });

      test('tooManyRequests sends 429', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.tooManyRequests() as Map<String, dynamic>;
        expect(result['error'], 'Too Many Requests');
        expect(mockContext.res.lastStatusCode, 429);
      });

      test('tooManyRequests with retryAfter', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.tooManyRequests(message: 'Slow down', retryAfter: 60)
                as Map<String, dynamic>;
        expect(result['retryAfter'], 60);
        expect(result['message'], 'Slow down');
      });

      test('serviceUnavailable sends 503', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.serviceUnavailable() as Map<String, dynamic>;
        expect(result['error'], 'Service Unavailable');
        expect(mockContext.res.lastStatusCode, 503);
      });

      test('serviceUnavailable with retryAfter', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.serviceUnavailable(message: 'Maintenance', retryAfter: 3600)
                as Map<String, dynamic>;
        expect(result['retryAfter'], 3600);
        expect(result['message'], 'Maintenance');
      });

      test('validationError sends 422 with field errors', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result =
            res.validationError({
                  'email': ['required', 'invalid format'],
                })
                as Map<String, dynamic>;
        expect(result['error'], 'Validation Error');
        expect(result['errors'], {
          'email': ['required', 'invalid format'],
        });
        expect(mockContext.res.lastStatusCode, 422);
      });
    });

    group('additional helpers', () {
      test('send delegates to text', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final result = res.send(
          body: 'custom',
          statusCode: 418,
          headers: {'X-Custom': 'val'},
        );
        expect(result, 'custom');
        expect(mockContext.res.lastStatusCode, 418);
        expect(mockContext.res.lastHeaders, {'X-Custom': 'val'});
      });

      test('downloadFile sends binary with headers', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final data = Uint8List.fromList([1, 2, 3]);
        res.downloadFile(data, 'test.pdf', mimeType: 'application/pdf');

        expect(mockContext.res.lastHeaders, {
          'Content-Type': 'application/pdf',
          'Content-Disposition': 'attachment; filename="test.pdf"',
        });
      });

      test('downloadFile uses default mime type', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        final data = Uint8List.fromList([1, 2, 3]);
        res.downloadFile(data, 'file.bin');

        expect(
          mockContext.res.lastHeaders!['Content-Type'],
          'application/octet-stream',
        );
      });

      test('downloadJSON sends JSON as binary', () {
        final mockContext = _MockContext();
        final res = AppwriteResponse.fromContext(mockContext);
        res.downloadJSON({'users': []}, 'data.json');

        expect(mockContext.res.lastHeaders, {
          'Content-Type': 'application/json',
          'Content-Disposition': 'attachment; filename="data.json"',
        });
      });
    });
  });

  group('PrettyToStringMixin', () {
    test('toString returns pretty JSON when enabled', () {
      AppwriteLogger.prettyPrint = true;
      final obj = _PrettyObject({'key': 'value'});
      final result = obj.toString();
      expect(result, contains('"key"'));
      expect(result, contains('"value"'));
      expect(result, contains('\n'));
    });

    test('toString returns compact format when disabled', () {
      AppwriteLogger.prettyPrint = false;
      final obj = _PrettyObject({'key': 'value'});
      final result = obj.toString();
      expect(result, contains('key'));
      expect(result, isNot(contains('\n')));
      AppwriteLogger.prettyPrint = true; // Reset
    });
  });

  group('messageToString', () {
    test('returns empty string for null', () {
      expect(messageToString(null), '');
    });

    test('returns string as-is', () {
      expect(messageToString('hello'), 'hello');
    });

    test('converts non-string to string', () {
      expect(messageToString(42), '42');
      expect(messageToString(true), 'true');
    });
  });
}

class _PrettyObject with PrettyToStringMixin {
  _PrettyObject(this._map);
  final Map<String, dynamic> _map;

  @override
  Map<String, dynamic> toMap() => _map;
}

class _MockContext {
  _MockContext({
    String? bodyText,
    Map<String, dynamic>? bodyJson,
    List<int>? bodyBinary,
    Map<String, dynamic>? headers,
    String? scheme,
    String? method,
    String? url,
    String? host,
    Object? port,
    String? path,
    String? queryString,
    Map<String, dynamic>? query,
  }) : req = _MockReq(
         bodyText: bodyText ?? '',
         bodyJson: bodyJson,
         bodyBinary: bodyBinary,
         headers: headers ?? <String, dynamic>{},
         scheme: scheme ?? 'https',
         method: method ?? 'GET',
         url: url ?? 'https://example.com',
         host: host ?? 'example.com',
         port: port ?? 443,
         path: path ?? '/',
         queryString: queryString ?? '',
         query: query ?? <String, dynamic>{},
       );

  final List<String> logMessages = [];
  final List<String> errorMessages = [];
  final _MockReq req;
  final res = _MockRes();

  void log(String message) {
    logMessages.add(message);
  }

  void error(String message) {
    errorMessages.add(message);
  }
}

class _MockReq {
  _MockReq({
    required this.bodyText,
    required this.bodyJson,
    required this.bodyBinary,
    required this.headers,
    required this.scheme,
    required this.method,
    required this.url,
    required this.host,
    required this.port,
    required this.path,
    required this.queryString,
    required this.query,
  });

  final String? bodyText;
  final Map<String, dynamic>? bodyJson;
  final List<int>? bodyBinary;
  final Map<String, dynamic>? headers;
  final String? scheme;
  final String? method;
  final String? url;
  final String? host;
  final Object? port;
  final String? path;
  final String? queryString;
  final Map<String, dynamic>? query;
}

class _MockRes {
  int? lastStatusCode;
  Map<String, String>? lastHeaders;

  dynamic json(Map<String, dynamic> data, int statusCode) {
    lastStatusCode = statusCode;
    return data;
  }

  dynamic empty() => null;

  dynamic text(String body, int statusCode, Map<String, String> headers) {
    lastStatusCode = statusCode;
    lastHeaders = headers;
    return body;
  }

  dynamic binary(Uint8List data, int statusCode, Map<String, String> headers) {
    lastStatusCode = statusCode;
    lastHeaders = headers;
    return data;
  }

  dynamic redirect(String url, int statusCode) {
    lastStatusCode = statusCode;
    return url;
  }
}
