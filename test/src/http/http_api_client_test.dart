import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:api_tools/api_tools.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/utils.dart';
import 'package:http/testing.dart';

class SUTWrapper {
  HttpAPIClient sut;

  SUTWrapper({this.sut});
}

const String _BASE_URL = "https://www.google.com";
void main() {
  group("HttpAPIClient", () {
    SUTWrapper makeSUT(
        {String baseURL = _BASE_URL,
        Future<http.Response> Function(http.Request) fn}) {
      var client = MockClient(fn);

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
}
