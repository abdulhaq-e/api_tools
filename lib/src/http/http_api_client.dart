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
    String url;
    if (endpoint.resolveAgainstBaseURL) {
      var _modifiedPath = endpoint.path.startsWith("/")
          ? endpoint.path.replaceFirst("/", "")
          : endpoint.path;
      url = path.join(baseURL, _modifiedPath);
    } else {
      url = endpoint.path;
    }
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
}
