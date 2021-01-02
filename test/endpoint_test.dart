import 'package:flutter_test/flutter_test.dart';

import 'package:api_tools/api_tools.dart';

void main() {
  group("Endpoint", () {
    test("set defaults", () {
      var sut = Endpoint(path: "foo", httpMethod: HttpMethod.get);
      expect(sut.path, 'foo');
      expect(sut.httpMethod, HttpMethod.get);
      expect(sut.queryParameters.isEmpty, true);
      expect(sut.data, null);
      expect(sut.acceptType, MIMEType.application_json);
      expect(sut.contentType, MIMEType.application_json);
      expect(sut.resolveAgainstBaseURL, true);
    });

    test("copyWith should generate a new Endpoint with passed objects", () {
      var p = "foo";
      var m = HttpMethod.get;
      var sut = Endpoint(path: p, httpMethod: m);
      expect(sut.copyWith(httpMethod: HttpMethod.post),
          Endpoint(path: p, httpMethod: HttpMethod.post),
          reason: "Failed httpMethod comparison");
      expect(sut.copyWith(path: "bar"), Endpoint(path: "bar", httpMethod: m),
          reason: "Failed path comparison");
      expect(sut.copyWith(queryParameters: {"a": "b"}),
          Endpoint(path: p, httpMethod: m, queryParameters: {"a": "b"}),
          reason: "Failed queryParams comparison");
      expect(sut.copyWith(headers: {"c": "d"}),
          Endpoint(path: p, httpMethod: m, headers: {"c": "d"}),
          reason: "Failed headers comparison");
      expect(
          sut.copyWith(contentType: MIMEType.multipart_form_data),
          Endpoint(
              path: p,
              httpMethod: m,
              contentType: MIMEType.multipart_form_data),
          reason: "Failed contentType comparison");
      expect(
          sut.copyWith(acceptType: MIMEType.multipart_form_data),
          Endpoint(
              path: p, httpMethod: m, acceptType: MIMEType.multipart_form_data),
          reason: "Failed acceptType comparison");
      expect(sut.copyWith(resolveAgainstBaseURL: false),
          Endpoint(path: p, httpMethod: m, resolveAgainstBaseURL: false),
          reason: "Failed resolveAgainstBaseURL comparison");
      expect(sut.copyWith(data: "spam"),
          Endpoint(path: p, httpMethod: m, data: "spam"),
          reason: "Failed data comparison");
    });
  });
}
