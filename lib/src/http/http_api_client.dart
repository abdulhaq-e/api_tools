import 'dart:convert';

import 'package:api_tools/api_tools.dart';
import 'package:http/http.dart';
import 'package:http/src/utils.dart';
import 'package:path/path.dart' as path;

class HttpAPIClient implements APIClient {
  String baseURL;
  BaseClient client;

  HttpAPIClient({this.baseURL, this.client});

  @override
  Future<APIResponse> request(Endpoint endpoint) async {
    String url = _generateUrl(
        baseUrl: baseURL,
        endpointPath: endpoint.path,
        resolveAgainstBaseURL: endpoint.resolveAgainstBaseURL);

    if (endpoint.queryParameters.isNotEmpty) {
      url = [url, "?", mapToQuery(endpoint.queryParameters, encoding: utf8)]
          .join();
    }

    Uri uri = Uri.parse(url);
    Response response;
    Map<String, String> headers = {
      contentTypeHeaderKey: mimeTypeValue(endpoint.contentType),
      acceptTypeHeaderKey: mimeTypeValue(endpoint.acceptType),
      ...endpoint.headers
    };
    switch (endpoint.httpMethod) {
      case HttpMethod.post:
        response =
            await client.post(uri, body: endpoint.data, headers: headers);
        break;
      case HttpMethod.get:
        response = await client.get(uri, headers: headers);
        break;
      case HttpMethod.put:
        response = await client.put(uri, body: endpoint.data, headers: headers);
        break;
      case HttpMethod.delete:
        response = await client.delete(uri, headers: headers);
        break;
      case HttpMethod.patch:
        response =
            await client.patch(uri, body: endpoint.data, headers: headers);
        break;
      default:
        break;
    }

    if (response != null) {
      return APIResponse(
          data: response.body,
          statusCode: response.statusCode,
          headers: response.headers);
    }
  }

  @override
  Future<APIResponse> requestMultipart(EndpointMultipart endpoint) async {
    String url = _generateUrl(
        baseUrl: baseURL,
        endpointPath: endpoint.path,
        resolveAgainstBaseURL: endpoint.resolveAgainstBaseURL);

    Uri uri = Uri.parse(url);
    Response response;
    String method = _HTTP_METHODS_STRINGS_MAP[endpoint.httpMethod];
    var request = MultipartRequest(method, uri);
    request.headers.addAll(endpoint.headers);
    request.fields.addAll(endpoint.fields);
    request.files.addAll(endpoint.files
        .map((x) =>
            MultipartFile.fromBytes(x.fieldName, x.bytes, filename: x.fileName))
        .toList());
    await client.send(request);
    if (response != null) {
      return APIResponse(
          data: response.body,
          statusCode: response.statusCode,
          headers: response.headers);
    }
  }

  String _generateUrl(
      {String endpointPath, String baseUrl, bool resolveAgainstBaseURL}) {
    String url = baseURL;
    if (resolveAgainstBaseURL) {
      var _modifiedPath = endpointPath.startsWith("/")
          ? endpointPath.replaceFirst("/", "")
          : endpointPath;
      url = path.join(baseURL, _modifiedPath);
    } else {
      url = endpointPath;
    }

    return url;
  }
}

const Map<HttpMethod, String> _HTTP_METHODS_STRINGS_MAP = {
  HttpMethod.get: "GET",
  HttpMethod.put: "PUT",
  HttpMethod.post: "POST",
  HttpMethod.delete: "DELETE",
  HttpMethod.patch: "PATCHs"
};
