import 'package:equatable/equatable.dart';
import 'package:api_tools/api_tools.dart';

class EndpointMultipartFileMediaType extends Equatable {
  final String type;
  final String subtype;

  EndpointMultipartFileMediaType({required this.type, required this.subtype});

  @override
  List<Object?> get props => [type, subtype];
}

class EndpointMultipartFile extends Equatable {
  final String fieldName;
  final String fileName;
  final EndpointMultipartFileMediaType mediaType;
  final List<int> bytes;

  EndpointMultipartFile(
      {required this.fieldName,
      required this.fileName,
      required this.bytes,
      required this.mediaType});

  @override
  List<Object?> get props => [fieldName, fileName, bytes, mediaType];
}

class EndpointMultipart extends Equatable {
  final String path;
  final HttpMethod httpMethod;
  final Map<String, String> headers;

  final Map<String, String> fields;
  final List<EndpointMultipartFile> files;
  final bool resolveAgainstBaseURL;

  EndpointMultipart({
    required this.path,
    required this.httpMethod,
    this.headers = const <String, String>{},
    this.fields = const <String, String>{},
    this.files = const [],
    this.resolveAgainstBaseURL = true,
  });

  EndpointMultipart copyWith({
    String? path,
    HttpMethod? httpMethod,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<EndpointMultipartFile>? files,
    bool? resolveAgainstBaseURL,
  }) {
    return EndpointMultipart(
        path: path ?? this.path,
        httpMethod: httpMethod ?? this.httpMethod,
        fields: fields ?? this.fields,
        files: files ?? this.files,
        headers: headers ?? this.headers,
        resolveAgainstBaseURL:
            resolveAgainstBaseURL ?? this.resolveAgainstBaseURL);
  }

  @override
  String toString() {
    return "EndpointMultipart<path: $path, "
        "httpMethod: $httpMethod, "
        "fields: $fields, "
        "headers: $headers, "
        "fiels: $files, "
        "resolveAgainstBaseURL:  $resolveAgainstBaseURL>";
  }

  @override
  List<Object?> get props => [
        path,
        httpMethod,
        fields,
        headers,
        files,
        resolveAgainstBaseURL,
      ];
}
