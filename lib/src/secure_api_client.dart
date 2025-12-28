import 'package:api_tools/api_tools.dart';

class SecureAPIClient extends APIClient {
  APIClient client;
  TokenProvider tokenProvider;
  String authHeaderKey;
  String authTokenPrefix;
  Map<String, String>? additionalHeaders;

  SecureAPIClient({
    required this.client,
    required this.tokenProvider,
    this.authHeaderKey = "Authorization",
    this.authTokenPrefix = "Bearer",
    this.additionalHeaders,
  });
  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    final token = await tokenProvider.getToken();
    Map<String, String> headers = {
      ...endpoint.headers,
      this.authHeaderKey: '$authTokenPrefix $token',
      ...(this.additionalHeaders ?? {}),
    };
    return client.request(endpoint.copyWith(headers: headers));
  }

  @override
  Future<APIResponse> requestMultipart(EndpointMultipart endpoint) async {
    final token = await tokenProvider.getToken();
    Map<String, String> headers = {
      ...endpoint.headers,
      this.authHeaderKey: '$authTokenPrefix $token',
      ...(this.additionalHeaders ?? {}),
    };
    return client.requestMultipart(endpoint.copyWith(headers: headers));
  }
}
