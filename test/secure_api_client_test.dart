import 'dart:convert';
import 'dart:typed_data';

import 'package:api_tools/api_tools.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:api_tools/src/testing.dart';

APIResponse createDummyResponse() {
  return APIResponse(
      data: utf8.encode("input") as Uint8List,
      headers: Map<String, String>(),
      statusCode: 200);
}

class MockTokenProvider implements TokenProvider {
  final String token;
  int getTokenCallCount = 0;

  MockTokenProvider(this.token);

  @override
  Future<String> getToken() async {
    getTokenCallCount++;
    return token;
  }
}

class ThrowingTokenProvider implements TokenProvider {
  final Exception exception;

  ThrowingTokenProvider(this.exception);

  @override
  Future<String> getToken() async {
    throw exception;
  }
}

void main() {
  group("SecureAPIClient", () {
    group("request", () {
      test("should set authorization header with default key and value prefix",
          () async {
        late Endpoint endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
          return Future.value(createDummyResponse());
        });
        var tokenProvider = MockTokenProvider("123");
        var sut = SecureAPIClient(client: client, tokenProvider: tokenProvider);
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "Bearer 123");
      });

      test("should set authorization header with custom key", () async {
        late Endpoint endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
          return Future.value(createDummyResponse());
        });

        var tokenProvider = MockTokenProvider("123");
        var sut = SecureAPIClient(
            client: client, tokenProvider: tokenProvider, authHeaderKey: "Auth");
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix", () async {
        late Endpoint endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
          return Future.value(createDummyResponse());
        });
        var tokenProvider = MockTokenProvider("123");
        var sut =
            SecureAPIClient(client: client, tokenProvider: tokenProvider, authTokenPrefix: "B");
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "B 123");
      });

      test("should call getToken() before making request", () async {
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          return Future.value(createDummyResponse());
        });
        var tokenProvider = MockTokenProvider("test-token");
        var sut = SecureAPIClient(client: client, tokenProvider: tokenProvider);

        expect(tokenProvider.getTokenCallCount, 0);
        await sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(tokenProvider.getTokenCallCount, 1);
      });

      test("should propagate exception when tokenProvider throws", () async {
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          return Future.value(createDummyResponse());
        });
        var exception = Exception("No token available");
        var tokenProvider = ThrowingTokenProvider(exception);
        var sut = SecureAPIClient(client: client, tokenProvider: tokenProvider);

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
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
          return Future.value(createDummyResponse());
        });
        var tokenProvider = MockTokenProvider("123");
        var sut = SecureAPIClient(client: client, tokenProvider: tokenProvider);

        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "Bearer 123");
      });

      test("should set authorization header with custom key", () async {
        late EndpointMultipart endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
          return Future.value(createDummyResponse());
        });
        var tokenProvider = MockTokenProvider("123");
        var sut = SecureAPIClient(
            client: client, tokenProvider: tokenProvider, authHeaderKey: "Auth");
        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix", () async {
        late EndpointMultipart endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
          return Future.value(createDummyResponse());
        });
        var tokenProvider = MockTokenProvider("123");
        var sut =
            SecureAPIClient(client: client, tokenProvider: tokenProvider, authTokenPrefix: "B");
        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "B 123");
      });

      test("should call getToken() before making request", () async {
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          return Future.value(createDummyResponse());
        });
        var tokenProvider = MockTokenProvider("test-token");
        var sut = SecureAPIClient(client: client, tokenProvider: tokenProvider);

        expect(tokenProvider.getTokenCallCount, 0);
        await sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(tokenProvider.getTokenCallCount, 1);
      });

      test("should propagate exception when tokenProvider throws", () async {
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          return Future.value(createDummyResponse());
        });
        var exception = Exception("No token available");
        var tokenProvider = ThrowingTokenProvider(exception);
        var sut = SecureAPIClient(client: client, tokenProvider: tokenProvider);

        expect(
          () => sut.requestMultipart(
              EndpointMultipart(path: "spam", httpMethod: HttpMethod.get)),
          throwsA(equals(exception)),
        );
      });
    });
  });
}
