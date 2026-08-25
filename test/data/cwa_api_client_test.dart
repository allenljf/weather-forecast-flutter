import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/data/cwa_api_client.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';

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

String fixture(String name) =>
    File('test/fixtures/cwa/$name').readAsStringSync();

/// 格式錯誤的變體一律**由實測存下的正常回應衍生**，並在呼叫端就地說明改了什麼；
/// 不使用憑空杜撰的假資料，否則測的是想像中的 API 而不是真的那一個。
String singleLocationWith(void Function(List<dynamic> weatherElement) change) {
  final json = jsonDecode(
    fixture('forecast_single_location.json'),
  ) as Map<String, dynamic>;
  final records = json['records'] as Map<String, dynamic>;
  final location = (records['location'] as List).single as Map<String, dynamic>;
  change(location['weatherElement'] as List);
  return jsonEncode(json);
}

/// 取出查詢失敗時的 [Failure]；成功回傳就讓測試當場失敗。
Future<Failure> failureFrom(CwaApiClient client) async {
  try {
    await client.fetchForecast('臺北市');
  } on CwaApiException catch (error) {
    return error.failure;
  }
  fail('預期查詢失敗，但它成功了');
}

/// 以固定回應建立受測的 client；回傳 adapter 以便檢查實際送出的請求。
({CwaApiClient client, FakeHttpClientAdapter adapter}) clientReplying(
  Future<ResponseBody> Function(RequestOptions options) respond,
) {
  final adapter = FakeHttpClientAdapter(respond);
  return (
    client: CwaApiClient(token: 'CWA-TEST-TOKEN', httpClientAdapter: adapter),
    adapter: adapter,
  );
}

({CwaApiClient client, FakeHttpClientAdapter adapter}) clientReplyingJson(
  String body, {
  int statusCode = 200,
}) => clientReplying(
  (_) async => ResponseBody.fromString(
    body,
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  ),
);

void main() {
  group('CWA API client', () {
    test('正常回應解析成三個預報時段，數值全部落在對的欄位', () async {
      final client = clientReplyingJson(
        fixture('forecast_single_location.json'),
      ).client;

      final slots = await client.fetchForecast('臺北市');

      expect(slots, hasLength(3));
      expect(
        slots.first,
        ForecastSlot(
          startTime: DateTime(2026, 8, 25, 6),
          endTime: DateTime(2026, 8, 25, 18),
          weatherDescription: '陰短暫陣雨',
          weatherCode: 11,
          rainProbability: 70,
          minTemperature: 26,
          maxTemperature: 30,
          comfort: '舒適至悶熱',
        ),
      );
    });

    test('回應含多個縣市時取的是查詢的那一個，不是第一個', () async {
      // 兩筆的 fixture 裡臺北市排在高雄市前面；依索引取值會安靜地拿錯。
      final client = clientReplyingJson(fixture('forecast_two_locations.json'))
          .client;

      final slots = await client.fetchForecast('高雄市');

      expect(
        slots.first,
        ForecastSlot(
          startTime: DateTime(2026, 8, 25, 6),
          endTime: DateTime(2026, 8, 25, 18),
          weatherDescription: '陰短暫陣雨或雷雨',
          weatherCode: 18,
          rainProbability: 80,
          minTemperature: 26,
          maxTemperature: 27,
          comfort: '舒適至悶熱',
        ),
      );
    });

    test('授權碼只出現在 header，網址裡沒有它——錯誤畫面才敢顯示完整 URL', () async {
      final (:client, :adapter) = clientReplyingJson(
        fixture('forecast_single_location.json'),
      );

      await client.fetchForecast('臺北市');

      final request = adapter.requests.single;
      // 原樣送出，沒有 `Bearer ` 前綴——加了實測會 401。
      expect(request.headers['Authorization'], 'CWA-TEST-TOKEN');
      expect(request.uri.toString(), isNot(contains('CWA-TEST-TOKEN')));
      expect(request.uri.queryParameters, {'locationName': '臺北市'});
      expect(request.connectTimeout, const Duration(seconds: 15));
      expect(request.receiveTimeout, const Duration(seconds: 15));
    });

    test('五個天氣要素缺任一就整筆作廢，而不是顯示一個殘缺的畫面', () async {
      // 由正常回應刪掉降雨機率這一個要素。
      final body = singleLocationWith(
        (elements) => elements.removeWhere(
          (element) =>
              (element as Map<String, dynamic>)['elementName'] == 'PoP',
        ),
      );

      final failure = await failureFrom(clientReplyingJson(body).client);

      expect(failure, isA<MalformedResponse>());
      expect(failure.diagnostics, contains('PoP'));
    });

    test('實測存下的空要素回應同樣是格式錯誤', () async {
      final failure = await failureFrom(
        clientReplyingJson(fixture('forecast_empty_weather_elements.json'))
            .client,
      );

      expect(failure, isA<MalformedResponse>());
    });

    test('數值轉不成整數也算格式錯誤——寧可作廢也不顯示錯的降雨機率', () async {
      // 把降雨機率的數值從 "70" 改成不是數字的字串。
      final body = singleLocationWith((elements) {
        final pop = elements.firstWhere(
          (element) =>
              (element as Map<String, dynamic>)['elementName'] == 'PoP',
        ) as Map<String, dynamic>;
        final first = (pop['time'] as List).first as Map<String, dynamic>;
        (first['parameter'] as Map<String, dynamic>)['parameterName'] = '七成';
      });

      final failure = await failureFrom(clientReplyingJson(body).client);

      expect(failure, isA<MalformedResponse>());
      expect(failure.diagnostics, contains('七成'));
    });

    test('欄位型別與上游實測不符時是格式錯誤，不是靜默的型別轉換', () async {
      // 上游的數值一律是字串；這裡把它換成 JSON 數字。
      final body = singleLocationWith((elements) {
        final pop = elements.firstWhere(
          (element) =>
              (element as Map<String, dynamic>)['elementName'] == 'PoP',
        ) as Map<String, dynamic>;
        final first = (pop['time'] as List).first as Map<String, dynamic>;
        (first['parameter'] as Map<String, dynamic>)['parameterName'] = 70;
      });

      final failure = await failureFrom(clientReplyingJson(body).client);

      expect(failure, isA<MalformedResponse>());
    });

    test('回應根本不是 JSON 時是格式錯誤', () async {
      final failure = await failureFrom(
        clientReplyingJson('<html>maintenance</html>').client,
      );

      expect(failure, isA<MalformedResponse>());
    });

    test('location 空陣列回傳空清單——那不是格式錯誤，由上層判斷是誰的問題', () async {
      final client = clientReplyingJson(
        fixture('forecast_location_not_found.json'),
      ).client;

      expect(await client.fetchForecast('臺北市'), isEmpty);
    });

    test('401 回的是純文字而非 JSON，仍要被認出是憑證錯誤', () async {
      final client = clientReplying(
        (_) async => ResponseBody.fromString(
          fixture('unauthorized_401.txt'),
          401,
          headers: {
            Headers.contentTypeHeader: ['application/octet-stream'],
          },
        ),
      ).client;

      final failure = await failureFrom(client);

      expect(failure, isA<InvalidToken>());
      expect(failure.diagnostics, contains('401 Forbidden'));
      // 可展開的技術細節會原樣顯示這段，裡面不能有授權碼。
      expect(failure.diagnostics, isNot(contains('CWA-TEST-TOKEN')));
    });

    test('氣象署 5xx 是上游服務異常，不是使用者的問題', () async {
      final client = clientReplyingJson(
        '<html>Service Unavailable</html>',
        statusCode: 503,
      ).client;

      final failure = await failureFrom(client);

      expect(failure, isA<UpstreamFailure>());
      expect(failure.diagnostics, contains('HTTP 503'));
    });

    test('逾時算連線失敗，讓使用者拿得到重試按鈕', () async {
      final client = clientReplying(
        (options) async => throw DioException.connectionTimeout(
          timeout: CwaApiClient.timeout,
          requestOptions: options,
        ),
      ).client;

      final failure = await failureFrom(client);

      expect(failure, isA<ConnectionFailure>());
    });
  });
}
