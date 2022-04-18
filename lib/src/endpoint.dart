import 'package:equatable/equatable.dart';
import 'package:api_tools/api_tools.dart';

String contentTypeHeaderKey = "Content-Type";
String acceptTypeHeaderKey = "Accept";

class Endpoint extends Equatable {
  final String path;
  final HttpMethod httpMethod;
  final Map<String, String> queryParameters;
  final Map<String, String> headers;
  final MIMEType contentType;
  final MIMEType acceptType;
  final bool resolveAgainstBaseURL;
  final dynamic data;

  Endpoint(
      {required this.path,
      required this.httpMethod,
      this.queryParameters = const <String, String>{},
      this.headers = const <String, String>{},
      this.contentType = MIMEType.application_json,
      this.acceptType = MIMEType.application_json,
      this.resolveAgainstBaseURL = true,
      this.data});

  Endpoint copyWith(
      {String? path,
      HttpMethod? httpMethod,
      Map<String, String>? queryParameters,
      Map<String, String>? headers,
      MIMEType? contentType,
      MIMEType? acceptType,
      bool? resolveAgainstBaseURL,
      dynamic data}) {
    return Endpoint(
        path: path ?? this.path,
        httpMethod: httpMethod ?? this.httpMethod,
        queryParameters: queryParameters ?? this.queryParameters,
        headers: headers ?? this.headers,
        contentType: contentType ?? this.contentType,
        acceptType: acceptType ?? this.acceptType,
        resolveAgainstBaseURL:
            resolveAgainstBaseURL ?? this.resolveAgainstBaseURL,
        data: data ?? this.data);
  }

  @override
  String toString() {
    return "Endpoint<path: $path, "
        "httpMethod: $httpMethod, "
        "queryParameters: $queryParameters, "
        "headers: $headers, "
        "contentType: $contentType, "
        "acceptType: $acceptType, "
        "resolveAgainstBaseURL:  $resolveAgainstBaseURL, "
        "data: $data>";
  }

  @override
  List<Object?> get props => [
        path,
        httpMethod,
        queryParameters,
        headers,
        acceptType,
        contentType,
        resolveAgainstBaseURL,
        data
      ];
}
