import 'package:api_tools/api_tools.dart';

class SecureAPIClient extends APIClient {
  APIClient client;
  String token;
  String authHeaderKey;
  String authTokenPrefix;

  SecureAPIClient(
      {this.client,
      this.token,
      this.authHeaderKey = "Authorization",
      this.authTokenPrefix = "Bearer"});
  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    Map<String, String> headers = {
      ...endpoint.headers,
      this.authHeaderKey: '$authTokenPrefix $token'
    };
    return client.request(endpoint.copyWith(headers: headers));
  }
}
