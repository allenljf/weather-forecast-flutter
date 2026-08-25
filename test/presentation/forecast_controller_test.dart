import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/data/forecast_repository_provider.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_repository.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';
import 'package:weather_forecast/presentation/forecast_controller.dart';
import 'package:weather_forecast/presentation/forecast_view_state.dart';

/// 接縫 5：四態狀態機——輸入動作序列，觀察畫面狀態序列。（#14）
///
/// 替身放在 repository 上，因為那是上層唯一的資料入口（Q9）；狀態機本身完全
/// 不知道 HTTP 的存在，所以這裡的每一則都讀得像「使用者做了什麼、畫面變成什麼」。
void main() {
  test('尚未送出任何查詢時停在初始狀態', () {
    final container = ProviderContainer.test();

    expect(container.read(forecastControllerProvider), isA<ForecastInitial>());
  });

  test('查詢成功時先進讀取中，再停在氣象資料', () async {
    final upstream = Completer<ForecastResult>();
    final container = containerServedBy(repositoryAnswering(upstream.future));
    final states = observedStates(container);

    final query = container
        .read(forecastControllerProvider.notifier)
        .search('台北');
    expect(
      container.read(forecastControllerProvider),
      isA<ForecastLoading>(),
      reason: '按下確認後必須立刻看到進行中指示，不能等到回應才變',
    );
    upstream.complete(ForecastAvailable([slot]));
    await query;

    expect(states, [isA<ForecastLoading>(), isA<ForecastData>()]);
    final data = states.last as ForecastData;
    expect(data.locationName, '臺北市', reason: '顯示的是正規化後的正式名稱');
    expect(data.slots, [slot]);
  });

  test('repository 回失敗時先進讀取中，再停在錯誤', () async {
    final failure = ConnectionFailure(
      detail: 'connection timeout',
      requestUri: _anyUri,
    );
    final container = containerServedBy(
      repositoryAnswering(Future.value(ForecastFailed(failure))),
    );
    final states = observedStates(container);

    await container.read(forecastControllerProvider.notifier).search('臺北市');

    expect(states, [isA<ForecastLoading>(), isA<ForecastError>()]);
    expect((states.last as ForecastError).failure, same(failure));
  });

  test('無效查詢直接進錯誤，不經過讀取中也不打上游', () async {
    final repository = repositoryAnswering(
      Future.value(ForecastAvailable([slot])),
    );
    final container = containerServedBy(repository);
    final states = observedStates(container);

    await container.read(forecastControllerProvider.notifier).search('火星');

    expect(states, [isA<ForecastError>()], reason: '本地就擋下了，沒有東西在讀取');
    final failure = (states.last as ForecastError).failure;
    expect(failure, isA<InvalidQuery>());
    expect((failure as InvalidQuery).query, '火星', reason: '文案要回述使用者打的原文');
    verifyNever(() => repository.fetchForecast(any()));
  });

  test('錯誤之後重新查詢會再走一次讀取中，回到氣象資料', () async {
    final repository = MockForecastRepository();
    var attempt = 0;
    when(() => repository.fetchForecast('臺北市')).thenAnswer(
      (_) async => attempt++ == 0
          ? ForecastFailed(
              ConnectionFailure(
                detail: 'connection timeout',
                requestUri: _anyUri,
              ),
            )
          : ForecastAvailable([slot]),
    );
    final container = containerServedBy(repository);
    final notifier = container.read(forecastControllerProvider.notifier);
    final states = observedStates(container);

    await notifier.search('臺北市');
    await notifier.search('臺北市');

    expect(states, [
      isA<ForecastLoading>(),
      isA<ForecastError>(),
      isA<ForecastLoading>(),
      isA<ForecastData>(),
    ]);
  });

  test('查詢還沒回來就改查別的縣市，晚到的舊回應不得覆蓋新狀態', () async {
    // 使用者按了「台北」，等不及又改查「台南」，然後臺北的回應才姍姍來遲。
    // 這個 bug 在手動測試中幾乎不會重現，只有把先發後到寫成確定性的順序才測得到。
    final taipei = Completer<ForecastResult>();
    final tainan = Completer<ForecastResult>();
    final repository = MockForecastRepository();
    when(() => repository.fetchForecast('臺北市'))
        .thenAnswer((_) => taipei.future);
    when(() => repository.fetchForecast('臺南市'))
        .thenAnswer((_) => tainan.future);
    final container = containerServedBy(repository);
    final notifier = container.read(forecastControllerProvider.notifier);

    final first = notifier.search('台北');
    final second = notifier.search('台南');
    tainan.complete(ForecastAvailable([slot]));
    await second;
    taipei.complete(ForecastAvailable([slot]));
    await first;

    final state = container.read(forecastControllerProvider) as ForecastData;
    expect(state.locationName, '臺南市', reason: '看到的必須是最後查的那一個');
  });

  test('舊查詢的失敗晚到，不得把已經顯示的氣象資料打成錯誤', () async {
    final taipei = Completer<ForecastResult>();
    final tainan = Completer<ForecastResult>();
    final repository = MockForecastRepository();
    when(() => repository.fetchForecast('臺北市'))
        .thenAnswer((_) => taipei.future);
    when(() => repository.fetchForecast('臺南市'))
        .thenAnswer((_) => tainan.future);
    final container = containerServedBy(repository);
    final notifier = container.read(forecastControllerProvider.notifier);

    final first = notifier.search('臺北市');
    final second = notifier.search('臺南市');
    tainan.complete(ForecastAvailable([slot]));
    await second;
    taipei.complete(
      ForecastFailed(
        ConnectionFailure(detail: 'connection timeout', requestUri: _anyUri),
      ),
    );
    await first;

    expect(container.read(forecastControllerProvider), isA<ForecastData>());
  });

  test('讀取中改打無效查詢，錯誤畫面不會被晚到的舊成功回應蓋掉', () async {
    final taipei = Completer<ForecastResult>();
    final container = containerServedBy(repositoryAnswering(taipei.future));
    final notifier = container.read(forecastControllerProvider.notifier);

    final first = notifier.search('臺北市');
    await notifier.search('火星');
    taipei.complete(ForecastAvailable([slot]));
    await first;

    expect(
      container.read(forecastControllerProvider),
      isA<ForecastError>(),
      reason: '無效查詢也是一次查詢，同樣讓仍在飛的舊請求作廢',
    );
  });
}

/// 觀察狀態序列而不是只看終點：四態的價值在轉移路徑上，只斷言最後一個狀態的
/// 測試會漏掉「跳過讀取中」這種 bug。
List<ForecastViewState> observedStates(ProviderContainer container) {
  final states = <ForecastViewState>[];
  container.listen(forecastControllerProvider, (_, next) => states.add(next));
  return states;
}

ProviderContainer containerServedBy(ForecastRepository repository) =>
    ProviderContainer.test(
      overrides: [forecastRepositoryProvider.overrideWithValue(repository)],
    );

ForecastRepository repositoryAnswering(Future<ForecastResult> result) {
  final repository = MockForecastRepository();
  when(() => repository.fetchForecast(any())).thenAnswer((_) => result);
  return repository;
}

final slot = ForecastSlot(
  startTime: DateTime(2026, 8, 25, 18),
  endTime: DateTime(2026, 8, 26, 6),
  weatherDescription: '多雲時晴',
  weatherCode: 4,
  rainProbability: 10,
  minTemperature: 27,
  maxTemperature: 31,
  comfort: '悶熱',
);

class MockForecastRepository extends Mock implements ForecastRepository {}

/// 狀態機不在乎請求網址長什麼樣，它只負責把失敗原封不動交給畫面。
final _anyUri = Uri.parse('https://opendata.cwa.gov.tw/');
