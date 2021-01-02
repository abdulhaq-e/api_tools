import 'package:api_tools/src/endpoint.dart';

class APIResponse {
  dynamic data;
  Map<String, dynamic> headers;
  int statusCode;

  APIResponse({this.data, this.headers, this.statusCode});
}

class APIError implements Exception {
  APIResponse response;
  APIErrorType type;
  dynamic error;
  APIError({this.response, this.type, this.error});
}

enum APIErrorType { timeout, response, cancel, general }

abstract class APIClient {
  Future<APIResponse> request(Endpoint endpoint);
}
