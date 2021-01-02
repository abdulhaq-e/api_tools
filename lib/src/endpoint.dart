import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

enum MIMEType {
  application_json,
  multipart_form_data,
  text_plain,
  application_x_www_form_urlencoded,
  nil
}

String mimeTypeValue(MIMEType type) {
  switch (type) {
    case MIMEType.application_json:
      {
        return "application/json";
      }
      break;
    case MIMEType.multipart_form_data:
      {
        return "multipart/form-data";
      }
      break;
    case MIMEType.text_plain:
      {
        return "text/plain";
      }
      break;
    case MIMEType.application_x_www_form_urlencoded:
      {
        return "application/x-www-form-urlencoded";
      }
      break;
    case MIMEType.nil:
      {
        return "";
      }
      break;
  }

  return "";
}

enum HttpMethod { get, post, put, delete, patch }

String contentTypeHeaderKey = "Content-Type";
String acceptTypeHeaderKey = "Accept";

class Endpoint extends Equatable {
  String path;
  HttpMethod httpMethod;
  Map<String, String> queryParameters;
  Map<String, String> headers;
  MIMEType contentType;
  MIMEType acceptType;
  bool resolveAgainstBaseURL;
  dynamic data;

  Endpoint(
      {@required this.path,
      @required this.httpMethod,
      this.queryParameters = const <String, String>{},
      this.headers = const <String, String>{},
      this.contentType = MIMEType.application_json,
      this.acceptType = MIMEType.application_json,
      this.resolveAgainstBaseURL = true,
      this.data});

  Endpoint copyWith(
      {String path,
      HttpMethod httpMethod,
      Map<String, String> queryParameters,
      Map<String, String> headers,
      MIMEType contentType,
      MIMEType acceptType,
      bool resolveAgainstBaseURL,
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
  List<Object> get props => [
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
