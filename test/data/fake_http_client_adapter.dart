import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// 手寫的傳輸層替身。（Q12(a)）
///
/// 刻意不引入 `http_mock_adapter`：它兩年未更新，與 dio 5.11 的相容性未知（F20）。
class FakeHttpClientAdapter implements HttpClientAdapter {
  FakeHttpClientAdapter(this._respond);

  final Future<ResponseBody> Function(RequestOptions options) _respond;

  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requests.add(options);
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}

/// 實際呼叫上游後原封不動存下的回應。不使用憑空杜撰的假資料。
String fixture(String name) =>
    File('test/fixtures/cwa/$name').readAsStringSync();
