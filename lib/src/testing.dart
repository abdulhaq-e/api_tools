import 'dart:convert';
import 'dart:typed_data';

import 'package:api_tools/api_tools.dart';

APIResponse dummyAPIResponse() {
  return APIResponse(
      data: utf8.encode("input") as Uint8List,
      headers: Map<String, String>(),
      statusCode: 200);
}

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

class TokenProviderTestDouble implements TokenProvider {
  final String token;
  int getTokenCallCount = 0;
  int refreshTokenCallCount = 0;

  TokenProviderTestDouble(this.token);

  @override
  Future<String> getToken() async {
    getTokenCallCount++;
    return token;
  }

  @override
  Future<void> refreshToken() async {
    refreshTokenCallCount++;
  }
}

class ThrowingTokenProviderTestDouble implements TokenProvider {
  final Exception exception;

  ThrowingTokenProviderTestDouble(this.exception);

  @override
  Future<String> getToken() async {
    throw exception;
  }

  @override
  Future<void> refreshToken() async {
    throw exception;
  }
}

class ConfigurableTokenProviderTestDouble implements TokenProvider {
  int refreshCallCount = 0;
  int getTokenCallCount = 0;
  String currentToken = "initial-token";
  Exception? exceptionToThrow;
  Duration? refreshDelay;

  @override
  Future<String> getToken() async {
    getTokenCallCount++;
    return currentToken;
  }

  @override
  Future<void> refreshToken() async {
    if (refreshDelay != null) {
      await Future.delayed(refreshDelay!);
    }
    refreshCallCount++;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    currentToken = "refreshed-token-$refreshCallCount";
  }
}

class ConfigurableAPIClientTestDouble implements APIClient {
  int requestCallCount = 0;
  int requestMultipartCallCount = 0;
  List<APIResponse> responses = [];
  List<APIError?> errors = [];
  int currentResponseIndex = 0;

  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    requestCallCount++;
    if (currentResponseIndex < errors.length && errors[currentResponseIndex] != null) {
      final error = errors[currentResponseIndex];
      currentResponseIndex++;
      throw error!;
    }
    if (currentResponseIndex < responses.length) {
      final response = responses[currentResponseIndex];
      currentResponseIndex++;
      return response;
    }
    return dummyAPIResponse();
  }

  @override
  Future<APIResponse> requestMultipart(EndpointMultipart endpoint) async {
    requestMultipartCallCount++;
    if (currentResponseIndex < errors.length && errors[currentResponseIndex] != null) {
      final error = errors[currentResponseIndex];
      currentResponseIndex++;
      throw error!;
    }
    if (currentResponseIndex < responses.length) {
      final response = responses[currentResponseIndex];
      currentResponseIndex++;
      return response;
    }
    return dummyAPIResponse();
  }
}
