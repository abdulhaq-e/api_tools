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

void main() {
  group("RefreshableAPIClient", () {
    group("request", () {
      test("should pass through successful requests without refreshing", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        mockClient.responses = [createResponse(statusCode: 200)];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(mockClient.requestCallCount, 1);
        expect(tokenProvider.refreshCallCount, 0);
      });

      test("should refresh and retry on 401 response", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        // First request returns 401, second returns 200
        mockClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(mockClient.requestCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should refresh and retry on 401 APIError", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        // First request throws 401 error, second returns 200
        mockClient.errors = [create401Error()];
        mockClient.responses = [createResponse(statusCode: 200)];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(mockClient.requestCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should respect maxRetries parameter", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        // All requests return 401
        mockClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
        ];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
          maxRetries: 3,
        );

        final response = await client.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        // Should try 3 times total: initial + 2 retries
        expect(mockClient.requestCallCount, 3);
        expect(tokenProvider.refreshCallCount, 2);
        expect(response.statusCode, 401);
      });

      test("should not retry on non-401 errors", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        mockClient.errors = [
          APIError(
            response: createResponse(statusCode: 500),
            type: APIErrorType.response,
            error: "Server error",
          ),
        ];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        expect(
          () => client.request(Endpoint(path: "/test", httpMethod: HttpMethod.get)),
          throwsA(isA<APIError>()),
        );

        expect(mockClient.requestCallCount, 1);
        expect(tokenProvider.refreshCallCount, 0);
      });

      test("should handle multiple 401s with retries", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        // First two requests return 401, third returns 200
        mockClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        expect(response.statusCode, 200);
        expect(mockClient.requestCallCount, 3);
        expect(tokenProvider.refreshCallCount, 2);
      });

      test("should use default maxRetries of 3", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        // All requests return 401
        mockClient.responses = List.generate(5, (_) => createResponse(statusCode: 401));

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.request(
          Endpoint(path: "/test", httpMethod: HttpMethod.get),
        );

        // Default maxRetries is 3
        expect(mockClient.requestCallCount, 3);
        expect(tokenProvider.refreshCallCount, 2);
        expect(response.statusCode, 401);
      });
    });

    group("requestMultipart", () {
      test("should pass through successful requests without refreshing", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        mockClient.responses = [createResponse(statusCode: 200)];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(response.statusCode, 200);
        expect(mockClient.requestMultipartCallCount, 1);
        expect(tokenProvider.refreshCallCount, 0);
      });

      test("should refresh and retry on 401 response", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        mockClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(response.statusCode, 200);
        expect(mockClient.requestMultipartCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should refresh and retry on 401 APIError", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        mockClient.errors = [create401Error()];
        mockClient.responses = [createResponse(statusCode: 200)];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        final response = await client.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(response.statusCode, 200);
        expect(mockClient.requestMultipartCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
      });

      test("should respect maxRetries parameter", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();
        mockClient.responses = List.generate(5, (_) => createResponse(statusCode: 401));

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
          maxRetries: 2,
        );

        final response = await client.requestMultipart(
          EndpointMultipart(path: "/upload", httpMethod: HttpMethod.post),
        );

        expect(mockClient.requestMultipartCallCount, 2);
        expect(tokenProvider.refreshCallCount, 1);
        expect(response.statusCode, 401);
      });
    });

    group("integration scenarios", () {
      test("should handle concurrent requests with shared lock", () async {
        final tokenProvider = ConfigurableTokenProviderTestDouble();
        final lock = TokenRefreshLock(tokenProvider: tokenProvider);
        final mockClient = ConfigurableAPIClientTestDouble();

        // All requests return 401 first, then 200
        mockClient.responses = [
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
          createResponse(statusCode: 401),
          createResponse(statusCode: 200),
        ];

        final client = RefreshableAPIClient(
          client: mockClient,
          tokenRefreshLock: lock,
        );

        // Make multiple concurrent requests
        final futures = [
          client.request(Endpoint(path: "/test1", httpMethod: HttpMethod.get)),
          client.request(Endpoint(path: "/test2", httpMethod: HttpMethod.get)),
          client.request(Endpoint(path: "/test3", httpMethod: HttpMethod.get)),
        ];

        final responses = await Future.wait(futures);

        // All should succeed
        for (final response in responses) {
          expect(response.statusCode, 200);
        }

        // Should have made 6 total requests (each endpoint tried twice)
        expect(mockClient.requestCallCount, 6);

        // Token refresh count depends on timing but should be at least 1
        expect(tokenProvider.refreshCallCount, greaterThanOrEqualTo(1));
      });
    });
  });
}
