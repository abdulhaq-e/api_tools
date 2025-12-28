import 'package:api_tools/api_tools.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:api_tools/src/testing.dart';

({
  SecureAPIClient client,
  APIClient innerClient,
  TokenProvider tokenProvider,
}) makeSUT({
  APIClient? client,
  TokenProvider? tokenProvider,
  String? authHeaderKey,
  String? authTokenPrefix,
  Map<String, String>? additionalHeaders,
}) {
  final innerClient = client ??
      APIClientTestDouble(
        requestCallback: (_) => Future.value(dummyAPIResponse()),
        requestMultipartCallback: (_) => Future.value(dummyAPIResponse()),
      );
  final provider = tokenProvider ?? TokenProviderTestDouble("test-token");
  final secureClient = SecureAPIClient(
    client: innerClient,
    tokenProvider: provider,
    authHeaderKey: authHeaderKey ?? "Authorization",
    authTokenPrefix: authTokenPrefix ?? "Bearer",
    additionalHeaders: additionalHeaders,
  );
  return (
    client: secureClient,
    innerClient: innerClient,
    tokenProvider: provider
  );
}

void main() {
  group("SecureAPIClient", () {
    group("request", () {
      test("should set authorization header with default key and value prefix",
          () async {
        late Endpoint endpoint;
        final innerClient = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
          return Future.value(dummyAPIResponse());
        });
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          client: innerClient,
          tokenProvider: TokenProviderTestDouble("123"),
        );
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "Bearer 123");
      });

      test("should set authorization header with custom key", () async {
        late Endpoint endpoint;
        final innerClient = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
          return Future.value(dummyAPIResponse());
        });
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          client: innerClient,
          tokenProvider: TokenProviderTestDouble("123"),
          authHeaderKey: "Auth",
        );
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix",
          () async {
        late Endpoint endpoint;
        final innerClient = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
          return Future.value(dummyAPIResponse());
        });
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          client: innerClient,
          tokenProvider: TokenProviderTestDouble("123"),
          authTokenPrefix: "B",
        );
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "B 123");
      });

      test("should call getToken() before making request", () async {
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT();

        expect((tokenProvider as TokenProviderTestDouble).getTokenCallCount, 0);
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect((tokenProvider as TokenProviderTestDouble).getTokenCallCount, 1);
      });

      test("should propagate exception when tokenProvider throws", () async {
        final exception = Exception("No token available");
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          tokenProvider: ThrowingTokenProviderTestDouble(exception),
        );

        expect(
          () => sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get)),
          throwsA(equals(exception)),
        );
      });
    });

    group("requestMutipart", () {
      test("should set authorization header with default key and value prefix",
          () async {
        late EndpointMultipart endpoint;
        final innerClient = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
          return Future.value(dummyAPIResponse());
        });
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          client: innerClient,
          tokenProvider: TokenProviderTestDouble("123"),
        );

        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "Bearer 123");
      });

      test("should set authorization header with custom key", () async {
        late EndpointMultipart endpoint;
        final innerClient = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
          return Future.value(dummyAPIResponse());
        });
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          client: innerClient,
          tokenProvider: TokenProviderTestDouble("123"),
          authHeaderKey: "Auth",
        );
        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix",
          () async {
        late EndpointMultipart endpoint;
        final innerClient = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
          return Future.value(dummyAPIResponse());
        });
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          client: innerClient,
          tokenProvider: TokenProviderTestDouble("123"),
          authTokenPrefix: "B",
        );
        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "B 123");
      });

      test("should call getToken() before making request", () async {
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT();

        expect((tokenProvider as TokenProviderTestDouble).getTokenCallCount, 0);
        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect((tokenProvider as TokenProviderTestDouble).getTokenCallCount, 1);
      });

      test("should propagate exception when tokenProvider throws", () async {
        final exception = Exception("No token available");
        final (client: sut, innerClient: _, :tokenProvider) = makeSUT(
          tokenProvider: ThrowingTokenProviderTestDouble(exception),
        );

        expect(
          () => sut.requestMultipart(
              EndpointMultipart(path: "spam", httpMethod: HttpMethod.get)),
          throwsA(equals(exception)),
        );
      });
    });
  });
}
