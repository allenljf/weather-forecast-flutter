import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/data/cwa_api_client.dart';
import 'package:weather_forecast/data/cwa_forecast_repository.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_repository.dart';

import 'fake_http_client_adapter.dart';

/// 從上游的實際回應一路測到 repository 的回傳值。
///
/// 替身放在傳輸層而不是 client 上：這個接縫要回答的是「上游這樣回，上層會拿到
/// 什麼」，把 client 換掉就只剩下轉發被驗證，重構一次就會壞。
ForecastRepository repositoryReplying(String body, {int statusCode = 200}) =>
    CwaForecastRepository(
      CwaApiClient(
        token: 'CWA-TEST-TOKEN',
        httpClientAdapter: FakeHttpClientAdapter(
          (_) async => ResponseBody.fromString(body, statusCode),
        ),
      ),
    );

void main() {
  test('正常回應回傳三個預報時段', () async {
    final repository = repositoryReplying(
      fixture('forecast_single_location.json'),
    );

    final result = await repository.fetchForecast('臺北市');

    expect(result, isA<ForecastAvailable>());
    expect((result as ForecastAvailable).slots, hasLength(3));
  });

  test('上游回空陣列是「上游查無此縣市」，不是空白的成功', () async {
    // 實測存下的回應：上游對它不認得的縣市回 200 + success:"true" + 空陣列，
    // 從不告知輸入錯誤（F11）。空陣列是唯一可觀察的訊號。
    final repository = repositoryReplying(
      fixture('forecast_location_not_found.json'),
    );

    final result = await repository.fetchForecast('臺北市');

    final failure = (result as ForecastFailed).failure;
    expect(failure, isA<UpstreamMissingLocation>());
    // 白名單擋在前面（Q1），所以走到這裡只有一個成因：本地清單與上游脫鉤。
    expect(failure.diagnostics, contains('本地縣市清單可能已過期'));
    expect(
      (failure as UpstreamMissingLocation).requestUri.queryParameters,
      {'locationName': '臺北市'},
    );
  });

  test('憑證錯誤回傳失敗而不是拋例外——上層永遠不必 try/catch', () async {
    // 實測存下的 401：body 是純文字而非 JSON（F3）。
    final repository = repositoryReplying(
      fixture('unauthorized_401.txt'),
      statusCode: 401,
    );

    final result = await repository.fetchForecast('臺北市');

    expect((result as ForecastFailed).failure, isA<InvalidToken>());
  });

  test('介面可以被 mocktail 直接替身——#8 的狀態機才有邊界可測', () async {
    // 這一則的把關發生在編譯期：介面若被關成 final／sealed，或改成帶狀態的
    // 抽象類別，下面這個替身就建不出來。
    final repository = _MockForecastRepository();
    when(
      () => repository.fetchForecast(any()),
    ).thenAnswer((_) async => const ForecastFailed(InvalidQuery(query: '火星')));

    expect(await repository.fetchForecast('火星'), isA<ForecastFailed>());
  });
}

class _MockForecastRepository extends Mock implements ForecastRepository {}
