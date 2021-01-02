import 'package:api_tools/api_tools.dart';
import 'package:flutter_test/flutter_test.dart';

class APIClientTestDouble implements APIClient {
  Endpoint passedEndpoint;
  EndpointMultipart passedEndpointMultpart;

  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    passedEndpoint = endpoint;
  }

  @override
  Future<APIResponse> requestMultipart(EndpointMultipart endpoint) async {
    passedEndpointMultpart = endpoint;
  }
}

void main() {
  group("SecureAPIClient", () {
    group("request", () {
      test("should set authorization header with default key and value prefix",
          () {
        var client = APIClientTestDouble();
        var sut = SecureAPIClient(client: client, token: "123");
        sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(client.passedEndpoint.headers["Authorization"], "Bearer 123");
      });

      test("should set authorization header with custom key", () {
        var client = APIClientTestDouble();
        var sut = SecureAPIClient(
            client: client, token: "123", authHeaderKey: "Auth");
        sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(client.passedEndpoint.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix", () {
        var client = APIClientTestDouble();
        var sut =
            SecureAPIClient(client: client, token: "123", authTokenPrefix: "B");
        sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
        expect(client.passedEndpoint.headers["Authorization"], "B 123");
      });
    });

    group("requestMutipart", () {
      test("should set authorization header with default key and value prefix",
          () {
        var client = APIClientTestDouble();
        var sut = SecureAPIClient(client: client, token: "123");
        sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(client.passedEndpointMultpart.headers["Authorization"],
            "Bearer 123");
      });

      test("should set authorization header with custom key", () {
        var client = APIClientTestDouble();
        var sut = SecureAPIClient(
            client: client, token: "123", authHeaderKey: "Auth");
        sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(client.passedEndpointMultpart.headers["Auth"], "Bearer 123");
      });

      test("should set authorization header with custom token prefix", () {
        var client = APIClientTestDouble();
        var sut =
            SecureAPIClient(client: client, token: "123", authTokenPrefix: "B");
        sut.requestMultipart(
            EndpointMultipart(path: "spam", httpMethod: HttpMethod.get));
        expect(client.passedEndpointMultpart.headers["Authorization"], "B 123");
      });
    });
  });
}
