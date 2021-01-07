import 'package:api_tools/api_tools.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:api_tools/src/testing.dart';

void main() {
  group("SecureAPIClient", () {
    group("request", () {
      test("should set authorization header with default key and value prefix",
          () {
        Endpoint endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
        });
        var sut = SecureAPIClient(client: client, token: "123");
        sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "Bearer 123");
      });

      test("should set authorization header with custom key", () {
        Endpoint endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
        });

        var sut = SecureAPIClient(
            client: client, token: "123", authHeaderKey: "Auth");
        sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix", () {
        Endpoint endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestCallback: (e) {
          endpoint = e;
        });
        var sut =
            SecureAPIClient(client: client, token: "123", authTokenPrefix: "B");
        sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "B 123");
      });
    });

    group("requestMutipart", () {
      test("should set authorization header with default key and value prefix",
          () {
        EndpointMultipart endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
        });
        var sut = SecureAPIClient(client: client, token: "123");

        sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "Bearer 123");
      });

      test("should set authorization header with custom key", () {
        EndpointMultipart endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
        });
        var sut = SecureAPIClient(
            client: client, token: "123", authHeaderKey: "Auth");
        sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix", () {
        EndpointMultipart endpoint;
        // ignore: missing_return
        var client = APIClientTestDouble(requestMultipartCallback: (e) {
          endpoint = e;
        });
        var sut =
            SecureAPIClient(client: client, token: "123", authTokenPrefix: "B");
        sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(endpoint.headers["Authorization"], "B 123");
      });
    });
  });
}
