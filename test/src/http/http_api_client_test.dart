import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:api_tools/api_tools.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/utils.dart';
import 'package:http/testing.dart';
import 'package:http_parser/http_parser.dart';

class SUTWrapper {
  HttpAPIClient sut;

  SUTWrapper({this.sut});
}

const String _BASE_URL = "https://www.google.com";
void main() {
  group("HttpAPIClient", () {
    SUTWrapper makeSUT(
        {String baseURL = _BASE_URL,
        Future<http.Response> Function(http.Request) fn,
        Future<http.StreamedResponse> Function(
                http.BaseRequest, http.ByteStream)
            streamingFn}) {
      http.BaseClient client;
      if (fn != null) {
        client = MockClient(fn);
      } else if (streamingFn != null) {
        client = MockClient.streaming(streamingFn);
      }
      var sut = HttpAPIClient(baseURL: baseURL, client: client);
      return SUTWrapper(sut: sut);
    }

    http.Response _buildhttpResponse(
        {String body = "spam",
        int statusCode = 200,
        Map<String, String> headers = const {},
        http.Request request}) {
      return http.Response(body, statusCode,
          headers: headers, request: request);
    }

    http.StreamedResponse _buildhttpStreamedResponse(
        {String body = "spam",
        int statusCode = 200,
        Map<String, String> headers = const {},
        http.BaseRequest request}) {
      return http.StreamedResponse(Stream.value(utf8.encode(body)), statusCode,
          headers: headers, request: request);
    }

    group("request", () {
      group("url parsing", () {
        test("add Enpoint path to baseURL", () async {
          for (var m in HttpMethod.values) {
            var endpoint = Endpoint(
                path: "hibye", resolveAgainstBaseURL: true, httpMethod: m);
            http.Response httpResponse;
            var r = makeSUT(fn: (re) {
              httpResponse = _buildhttpResponse(request: re);
              return Future.value(httpResponse);
            });
            await r.sut.request(endpoint);
            expect(httpResponse.request.url, Uri.parse(_BASE_URL + "/hibye"),
                reason: "Failed uri parsing for $m request");
          }
        });

        test("add Enpoint path to baseURL, path starting with forwardslash",
            () async {
          for (var m in HttpMethod.values) {
            var endpoint = Endpoint(
                path: "/hibye", resolveAgainstBaseURL: true, httpMethod: m);
            http.Response httpResponse;
            var r = makeSUT(fn: (re) {
              httpResponse = _buildhttpResponse(request: re);
              return Future.value(httpResponse);
            });
            await r.sut.request(endpoint);
            expect(httpResponse.request.url, Uri.parse(_BASE_URL + "/hibye"),
                reason: "Failed uri parsing for $m request");
          }
        });

        test("add Enpoint queryParams to uri", () async {
          for (var m in HttpMethod.values) {
            var queryParams = {"a": "1", "b": "2", "c": "3"};
            var endpoint = Endpoint(
                path: "hibye", queryParameters: queryParams, httpMethod: m);
            http.Response httpResponse;
            var r = makeSUT(fn: (re) {
              httpResponse = _buildhttpResponse(request: re);
              return Future.value(httpResponse);
            });
            await r.sut.request(endpoint);
            expect(
                httpResponse.request.url,
                Uri.parse(_BASE_URL +
                    "/hibye?" +
                    mapToQuery(queryParams, encoding: utf8)),
                reason: "Failed uri parsing for $m request");
          }
        });
        test("use Enpoint path as uri", () async {
          for (var m in HttpMethod.values) {
            var endpoint = Endpoint(
                path: "hibye", resolveAgainstBaseURL: false, httpMethod: m);
            http.Response httpResponse;
            var r = makeSUT(fn: (re) {
              httpResponse = _buildhttpResponse(request: re);
              return Future.value(httpResponse);
            });
            await r.sut.request(endpoint);
            expect(httpResponse.request.url, Uri.parse("hibye"),
                reason: "Failed uri parsing for $m request");
          }
        });
      });

      group("setting correct headers", () {
        test("add Enpoint headers including contentType and acceptType",
            () async {
          for (var m in HttpMethod.values) {
            for (var mime in MIMEType.values) {
              var headers = {"Auth": "Token"};

              var endpoint =
                  Endpoint(path: "blabla", httpMethod: m, headers: headers);
              var expectedHeaders = {
                "Auth": "Token",
                "Content-Type": mimeTypeValue(endpoint.contentType),
                "Accept": mimeTypeValue(endpoint.acceptType)
              };
              http.Response httpResponse;
              var r = makeSUT(fn: (re) {
                httpResponse = _buildhttpResponse(request: re);
                return Future.value(httpResponse);
              });
              await r.sut.request(endpoint);
              expect(httpResponse.request.headers, expectedHeaders,
                  reason:
                      "Failed httper heasder for $m request using mime $mime");
            }
          }
        });
      });

      group("post", () {
        test("set correct body, json", () async {
          var data = jsonEncode({"a1": "1", "b2": "2"});
          var endpoint =
              Endpoint(path: "hibye", data: data, httpMethod: HttpMethod.post);
          http.Response httpResponse;
          var r = makeSUT(fn: (re) {
            httpResponse = _buildhttpResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.request(endpoint);
          expect((httpResponse.request as http.Request).body, data);
        });

        test("set correct body, form-endocded", () async {
          var data = {"a1": "1", "b2": "2"};
          var endpoint = Endpoint(
              path: "hibye",
              data: data,
              contentType: MIMEType.application_x_www_form_urlencoded,
              httpMethod: HttpMethod.post);
          http.Response httpResponse;
          var r = makeSUT(fn: (re) {
            httpResponse = _buildhttpResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.request(endpoint);
          expect((httpResponse.request as http.Request).bodyFields, data);
        });
      });

      group("put", () {
        test("set correct body, json", () async {
          var data = jsonEncode({"a1": "1", "b2": "2"});
          var endpoint =
              Endpoint(path: "hibye", data: data, httpMethod: HttpMethod.put);
          http.Response httpResponse;
          var r = makeSUT(fn: (re) {
            httpResponse = _buildhttpResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.request(endpoint);
          expect((httpResponse.request as http.Request).body, data);
        });

        test("set correct body, form-endocded", () async {
          var data = {"a1": "1", "b2": "2"};
          var endpoint = Endpoint(
              path: "hibye",
              data: data,
              contentType: MIMEType.application_x_www_form_urlencoded,
              httpMethod: HttpMethod.put);
          http.Response httpResponse;
          var r = makeSUT(fn: (re) {
            httpResponse = _buildhttpResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.request(endpoint);
          expect((httpResponse.request as http.Request).bodyFields, data);
        });
      });

      group("patch", () {
        test("set correct body, json", () async {
          var data = jsonEncode({"a1": "1", "b2": "2"});
          var endpoint =
              Endpoint(path: "hibye", data: data, httpMethod: HttpMethod.patch);
          http.Response httpResponse;
          var r = makeSUT(fn: (re) {
            httpResponse = _buildhttpResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.request(endpoint);
          expect((httpResponse.request as http.Request).body, data);
        });

        test("set correct body, form-endocded", () async {
          var data = {"a1": "1", "b2": "2"};
          var endpoint = Endpoint(
              path: "hibye",
              data: data,
              contentType: MIMEType.application_x_www_form_urlencoded,
              httpMethod: HttpMethod.patch);
          http.Response httpResponse;
          var r = makeSUT(fn: (re) {
            httpResponse = _buildhttpResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.request(endpoint);
          expect((httpResponse.request as http.Request).bodyFields, data);
        });
      });

      group("response", () {
        test("returns correct apiresponse", () async {
          for (var m in HttpMethod.values) {
            var endpoint = Endpoint(path: "hibye", httpMethod: m);
            http.Response httpResponse;
            var expectedBody = "helloWorld";
            var expectedStatusCode = 300;
            var expectedHeaders = {"Foo": "Bar"};
            var r = makeSUT(fn: (re) {
              httpResponse = _buildhttpResponse(
                  request: re,
                  statusCode: expectedStatusCode,
                  body: expectedBody,
                  headers: expectedHeaders);
              return Future.value(httpResponse);
            });
            var response = await r.sut.request(endpoint);
            expect(response.statusCode, expectedStatusCode,
                reason: "Failed handling response statusCode for $m request");
            expect(response.data, expectedBody,
                reason: "Failed handling response data for $m request");
            expect(response.headers, expectedHeaders,
                reason: "Failed handling response headers for $m request");
          }
        });

        test("throws an exception if the client throws one", () async {
          for (var m in HttpMethod.values) {
            var endpoint = Endpoint(path: "hibye", httpMethod: m);
            var r = makeSUT(fn: (re) {
              return Future.error(SocketException("Error"));
            });
            expect(() async => await r.sut.request(endpoint), throwsException);
          }
        });
      });
    });

    group("requestMultipart", () {
      test("add Enpoint path to baseURL", () async {
        for (var m in HttpMethod.values) {
          var endpoint = EndpointMultipart(
              path: "hibye", resolveAgainstBaseURL: true, httpMethod: m);
          http.StreamedResponse httpResponse;
          var r = makeSUT(streamingFn: (re, bs) {
            httpResponse = _buildhttpStreamedResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.requestMultipart(endpoint);
          expect(httpResponse.request.url, Uri.parse(_BASE_URL + "/hibye"),
              reason: "Failed uri parsing for $m request");
        }
      });

      test("add Enpoint path to baseURL, paths starting with /", () async {
        for (var m in HttpMethod.values) {
          var endpoint = EndpointMultipart(
              path: "/hibye", resolveAgainstBaseURL: true, httpMethod: m);
          http.StreamedResponse httpResponse;
          var r = makeSUT(streamingFn: (re, bs) {
            httpResponse = _buildhttpStreamedResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.requestMultipart(endpoint);
          expect(httpResponse.request.url, Uri.parse(_BASE_URL + "/hibye"),
              reason: "Failed uri parsing for $m request");
        }
      });

      test("use Enpoint path as uri", () async {
        for (var m in HttpMethod.values) {
          var endpoint = EndpointMultipart(
              path: "hibye", resolveAgainstBaseURL: false, httpMethod: m);
          http.StreamedResponse httpResponse;
          var r = makeSUT(streamingFn: (re, bs) {
            httpResponse = _buildhttpStreamedResponse(request: re);
            return Future.value(httpResponse);
          });
          await r.sut.requestMultipart(endpoint);
          expect(httpResponse.request.url, Uri.parse("hibye"),
              reason: "Failed uri parsing for $m request");
        }
      });

      test("sets headers", () async {
        var expectedHeaders = {"spam": "foo"};
        var endpoint = EndpointMultipart(
            path: "hibye",
            httpMethod: HttpMethod.get,
            headers: expectedHeaders);
        http.StreamedResponse httpResponse;
        var r = makeSUT(streamingFn: (re, bs) {
          httpResponse = _buildhttpStreamedResponse(request: re);
          return Future.value(httpResponse);
        });
        await r.sut.requestMultipart(endpoint);
        expect(httpResponse.request.headers["spam"], "foo",
            reason: "Failed comparing headers");
      });

      test("sets field ", () async {
        var expectedFields = {"fieldKey1": "fieldValue1"};
        var endpoint = EndpointMultipart(
            path: "hibye", httpMethod: HttpMethod.get, fields: expectedFields);
        http.StreamedResponse httpResponse;
        var r = makeSUT(streamingFn: (re, bs) {
          httpResponse = _buildhttpStreamedResponse(request: re);
          return Future.value(httpResponse);
        });
        await r.sut.requestMultipart(endpoint);
        expect((httpResponse.request as http.MultipartRequest).fields,
            expectedFields,
            reason: "Failed comparing fields");
      });

      test("sets files", () async {
        var expectedFiles = [
          EndpointMultipartFile(
              fieldName: "testFieldName",
              fileName: "testFileName",
              bytes: utf8.encode("testBytes"),
              mediaType: EndpointMultipartFileMediaType(
                  type: "image", subtype: "jpeg")),
        ];
        var endpoint = EndpointMultipart(
            path: "hibye", httpMethod: HttpMethod.get, files: expectedFiles);
        http.StreamedResponse httpResponse;
        var r = makeSUT(streamingFn: (re, bs) {
          httpResponse = _buildhttpStreamedResponse(request: re);
          return Future.value(httpResponse);
        });
        await r.sut.requestMultipart(endpoint);
        expect((httpResponse.request as http.MultipartRequest).files,
            predicate((List<http.MultipartFile> r) {
          var f = r.first;
          return (f.field == expectedFiles.first.fieldName) &&
              (f.filename == expectedFiles.first.fileName) &&
              (f.length == expectedFiles.first.bytes.length) &&
              (f.contentType.mimeType == "image/jpeg");
        }), reason: "Failed comparing files");
      });

      group("response", () {
        test("returns correct apiresponse", () async {
          var endpoint =
              EndpointMultipart(path: "hibye", httpMethod: HttpMethod.get);
          http.StreamedResponse httpResponse;
          var expectedBody = "helloWorld";
          var expectedStatusCode = 300;
          var expectedHeaders = {"Foo": "Bar"};
          var r = makeSUT(streamingFn: (re, bs) {
            httpResponse = _buildhttpStreamedResponse(
                request: re,
                statusCode: expectedStatusCode,
                body: expectedBody,
                headers: expectedHeaders);
            return Future.value(httpResponse);
          });
          var response = await r.sut.requestMultipart(endpoint);
          expect(response.statusCode, expectedStatusCode,
              reason: "Failed handling response statusCode");
          expect(response.data, expectedBody,
              reason: "Failed handling response data");
          expect(response.headers, expectedHeaders,
              reason: "Failed handling response headers");
        });

        test("throws an exception if the client throws one", () async {
          for (var m in HttpMethod.values) {
            var endpoint = EndpointMultipart(path: "hibye", httpMethod: m);

            var r = makeSUT(streamingFn: (re, bs) {
              return Future.error(SocketException("Error"));
            });
            expect(() async => await r.sut.requestMultipart(endpoint),
                throwsException);
          }
        });
      });
    });
  });
}
