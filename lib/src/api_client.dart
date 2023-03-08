import 'dart:typed_data';

import 'package:api_tools/api_tools.dart';

class APIResponse {
  Uint8List data;
  Map<String, dynamic> headers;
  int statusCode;

  APIResponse(
      {required this.data, required this.headers, required this.statusCode});
}

class APIError implements Exception {
  APIResponse response;
  APIErrorType type;
  dynamic error;
  APIError({required this.response, required this.type, required this.error});
}

enum APIErrorType { timeout, response, cancel, general }

abstract class APIClient {
  Future<APIResponse> request(Endpoint endpoint);
  Future<APIResponse> requestMultipart(EndpointMultipart endpoint);
}
