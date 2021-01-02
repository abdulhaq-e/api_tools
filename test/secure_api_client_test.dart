import 'package:api_tools/api_tools.dart';
import 'package:flutter_test/flutter_test.dart';

class APIClientTestDouble implements APIClient {
  Endpoint passedEndpoint;
  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    passedEndpoint = endpoint;
  }
}

void main() {
  group("SecureAPIClient", () {
    test("should set authorization header with default key and value prefix",
        () {
      var client = APIClientTestDouble();
      var sut = SecureAPIClient(client: client, token: "123");
      sut.request(Endpoint(path: "spam", httpMethod: HttpMethod.get));
      expect(client.passedEndpoint.headers["Authorization"], "Bearer 123");
    });

    test("should set authorization header with custom key", () {
      var client = APIClientTestDouble();
      var sut =
          SecureAPIClient(client: client, token: "123", authHeaderKey: "Auth");
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
}
