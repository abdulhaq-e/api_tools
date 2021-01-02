import 'package:flutter_test/flutter_test.dart';

import 'package:api_tools/api_tools.dart';

void main() {
  group("EndpointMultipart", () {
    test("set defaults", () {
      var sut = EndpointMultipart(path: "foo", httpMethod: HttpMethod.get);
      expect(sut.path, 'foo');
      expect(sut.httpMethod, HttpMethod.get);
      expect(sut.fields.isEmpty, true);
      expect(sut.files.isEmpty, true);
      expect(sut.headers.isEmpty, true);
      expect(sut.resolveAgainstBaseURL, true);
    });

    test("copyWith should generate a new EndpointMultipart with passed objects",
        () {
      var p = "foo";
      var m = HttpMethod.get;
      var sut = EndpointMultipart(path: p, httpMethod: m);
      expect(sut.copyWith(httpMethod: HttpMethod.post),
          EndpointMultipart(path: p, httpMethod: HttpMethod.post),
          reason: "Failed httpMethod comparison");
      expect(sut.copyWith(path: "bar"),
          EndpointMultipart(path: "bar", httpMethod: m),
          reason: "Failed path comparison");
      expect(sut.copyWith(fields: {"a": "b"}),
          EndpointMultipart(path: p, httpMethod: m, fields: {"a": "b"}),
          reason: "Failed fields comparison");
      expect(
          sut.copyWith(files: [EndpointMultipartFile()]),
          EndpointMultipart(
              path: p, httpMethod: m, files: [EndpointMultipartFile()]),
          reason: "Failed files comparison");
      expect(sut.copyWith(headers: {"c": "d"}),
          EndpointMultipart(path: p, httpMethod: m, headers: {"c": "d"}),
          reason: "Failed headers comparison");

      expect(
          sut.copyWith(resolveAgainstBaseURL: false),
          EndpointMultipart(
              path: p, httpMethod: m, resolveAgainstBaseURL: false),
          reason: "Failed resolveAgainstBaseURL comparison");
    });
  });
}
