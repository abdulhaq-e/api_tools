import 'package:api_tools/api_tools.dart';

class APIClientTestDouble implements APIClient {
  APIClientTestDouble({this.requestCallback, this.requestMultipartCallback});
  var requestCallCount = 0;
  var requestMultipartCallCount = 0;

  final Future<APIResponse> Function(Endpoint endpoint)? requestCallback;
  final Future<APIResponse> Function(EndpointMultipart endpoint)?
      requestMultipartCallback;

  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    requestCallCount += 1;
    if (requestCallback != null) {
      return requestCallback!(endpoint);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<APIResponse> requestMultipart(EndpointMultipart endpoint) async {
    requestMultipartCallCount += 1;
    if (requestMultipartCallback != null) {
      return requestMultipartCallback!(endpoint);
    } else {
      throw UnimplementedError();
    }
  }
}
