import 'dart:convert';
import 'dart:typed_data';

import 'package:api_tools/api_tools.dart';
import 'package:api_tools/src/refreshable_api_client.dart';
import 'package:api_tools/src/token_refresh_lock.dart';
import 'package:api_tools/src/testing.dart';
import 'package:flutter_test/flutter_test.dart';

APIResponse createResponse({int statusCode = 200, String data = "success"}) {
  return APIResponse(
    data: utf8.encode(data) as Uint8List,
    headers: {},
    statusCode: statusCode,
  );
}

APIError create401Error() {
  return APIError(
    response: createResponse(statusCode: 401, data: "Unauthorized"),
    type: APIErrorType.response,
    error: "Unauthorized",
  );
}

({
  RefreshableAPIClient client,
  ConfigurableAPIClientTestDouble innerClient,
  ConfigurableTokenProviderTestDouble tokenProvider,
  TokenRefreshLock lock,
}) makeSUT({
  ConfigurableAPIClientTestDouble? client,
  ConfigurableTokenProviderTestDouble? tokenProvider,
  int? maxRetries,
}) {
  final innerClient = client ?? ConfigurableAPIClientTestDouble();
  final provider = tokenProvider ?? ConfigurableTokenProviderTestDouble();
  final lock = TokenRefreshLock(tokenProvider: provider);
  final refreshableClient = RefreshableAPIClient(
    client: innerClient,
    tokenRefreshLock: lock,
    maxRetries: maxRetries ?? 3,
  );
  return (
    client: refreshableClient,
    innerClient: innerClient,
    tokenProvider: provider,
    lock: lock,
  );
}

void main() {
  group("RefreshableAPIClient", () {
    group("request", () {
      test("should pass through successful requests without refreshing", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        innerClient.responses = [createResponse(statusCode: 200)];

        final response = await sut.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(innerClient.requestCallCount, 1);
        expect(tokenProvider.refreshCallCount, 0);
      });

      test("should refresh and retry on 401 response", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        // First request returns 401, second returns 200
        innerClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        final response = await sut.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(innerClient.requestCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should refresh and retry on 401 APIError", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        // First request throws 401 error, second returns 200
        innerClient.errors = [create401Error()];
        innerClient.responses = [createResponse(statusCode: 200)];

        final response = await sut.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(innerClient.requestCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should respect maxRetries parameter", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT(maxRetries: 3);
        // All requests return 401
        innerClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
        ];

        final response = await sut.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        // Should try 3 times total: initial + 2 retries
        expect(innerClient.requestCallCount, 3);
        expect(tokenProvider.refreshCallCount, 2);
        expect(response.statusCode, 401);
      });

      test("should not retry on non-401 errors", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        innerClient.errors = [
          APIError(
            response: createResponse(statusCode: 500),
            type: APIErrorType.response,
            error: "Server error",
          ),
        ];

        expect(
          () => sut.request(Endpoint(path: "/test", httpMethod: HttpMethod.get)),
          throwsA(isA<APIError>()),
        );

        expect(innerClient.requestCallCount, 1);
        expect(tokenProvider.refreshCallCount, 0);
      });

      test("should handle multiple 401s with retries", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        // First two requests return 401, third returns 200
        innerClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        final response = await sut.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(innerClient.requestCallCount, 3);
        expect(tokenProvider.refreshCallCount, 2);
      });

      test("should use default maxRetries of 3", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        // All requests return 401
        innerClient.responses = List.generate(5, (_) => createResponse(statusCode: 401));

        final response = await sut.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        // Default maxRetries is 3
        expect(innerClient.requestCallCount, 3);
        expect(tokenProvider.refreshCallCount, 2);
        expect(response.statusCode, 401);
      });
    });

    group("requestMultipart", () {
      test("should pass through successful requests without refreshing", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        innerClient.responses = [createResponse(statusCode: 200)];

        final response = await sut.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(response.statusCode, 200);
        expect(innerClient.requestMultipartCallCount, 1);
        expect(tokenProvider.refreshCallCount, 0);
      });

      test("should refresh and retry on 401 response", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        innerClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        final response = await sut.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(response.statusCode, 200);
        expect(innerClient.requestMultipartCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should refresh and retry on 401 APIError", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();
        innerClient.errors = [create401Error()];
        innerClient.responses = [createResponse(statusCode: 200)];

        final response = await sut.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(response.statusCode, 200);
        expect(innerClient.requestMultipartCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should respect maxRetries parameter", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT(maxRetries: 2);
        innerClient.responses = List.generate(5, (_) => createResponse(statusCode: 401));

        final response = await sut.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(innerClient.requestMultipartCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
        expect(response.statusCode, 401);
      });
    });

    group("integration scenarios", () {
      test("should handle concurrent requests with shared lock", () async {
        final (client: sut, :innerClient, :tokenProvider, :lock) = makeSUT();

        // All requests return 401 first, then 200
        innerClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        // Make multiple concurrent requests
        final futures = [
          sut.request(Endpoint(path: "/test1", httpMethod: HttpMethod.get)),
          sut.request(Endpoint(path: "/test2", httpMethod: HttpMethod.get)),
          sut.request(Endpoint(path: "/test3", httpMethod: HttpMethod.get)),
        ];

        final responses = await Future.wait(futures);

        // All should succeed
        for (final response in responses) {
          expect(response.statusCode, 200);
        }

        // Should have made 6 total requests (each endpoint tried twice)
        expect(innerClient.requestCallCount, 6);

        // Token refresh count depends on timing but should be at least 1
        expect(tokenProvider.refreshCallCount, greaterThanOrEqualTo(1));
      });
    });
  });
}
