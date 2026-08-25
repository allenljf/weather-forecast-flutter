import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/data/forecast_repository_provider.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_repository.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';
import 'package:weather_forecast/presentation/forecast_controller.dart';
import 'package:weather_forecast/presentation/forecast_display.dart';

/// 接縫 5：四態狀態機——輸入動作序列，觀察畫面。（#14）
///
/// 這裡把觀察點放在**顯示出來的文字**上：四個狀態各有一句只屬於自己的話，
/// 因此「畫面現在是哪一個狀態」可以完全用文字尋找器判定，不觸碰任何內部欄位。
/// 狀態一律由真實的 notifier 驅動、替身只放在 repository 這個唯一的資料入口，
/// 所以這些測試在 widget 換一種排版之後仍然成立。
void main() {
  testWidgets('初始：還沒查之前給圖示與一句引導文字，而不是一片空白', (tester) async {
    await pumpDisplay(tester, neverAnswers());

    expect(find.text('輸入縣市名稱，查詢今明 36 小時天氣'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.text(loadingLabel), findsNothing);
  });

  testWidgets('讀取中：按下確認後立刻看到進行中指示與文字，而不是一個蓋住畫面的對話框', (tester) async {
    await pumpDisplay(tester, neverAnswers());

    unawaited(controllerOf(tester).search('台北'));
    await tester.pump();

    expect(
      find.text(loadingLabel),
      findsOneWidget,
      reason: '等 15 秒的人需要一句話，不能只有轉圈',
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(Dialog), findsNothing, reason: '需求明文要求 inline 呈現');
    expect(find.text('輸入縣市名稱，查詢今明 36 小時天氣'), findsNothing);
  });

  testWidgets('氣象資料：縣市名加三個時段，每段五個要素都看得到', (tester) async {
    await pumpDisplay(
      tester,
      repositoryAnswering(Future.value(ForecastAvailable(thirtySixHours))),
    );

    await controllerOf(tester).search('台南');
    await tester.pump();

    expect(find.text('臺南市'), findsOneWidget, reason: '使用者要能確認沒有查錯縣市');
    // 三段 × 12 小時 = 題目名稱裡的 36 小時；相對日省得使用者去讀完整年月日。
    expect(find.text('今日 18:00 ～ 明日 06:00'), findsOneWidget);
    expect(find.text('明日 06:00 ～ 明日 18:00'), findsOneWidget);
    expect(find.text('明日 18:00 ～ 後天 06:00'), findsOneWidget);

    expect(find.text('多雲時晴'), findsOneWidget);
    expect(find.text('27°C ～ 31°C'), findsOneWidget);
    expect(find.text('降雨機率 10%'), findsOneWidget);
    expect(find.text('舒適度 悶熱'), findsOneWidget);

    expect(find.text('午後短暫雷陣雨'), findsOneWidget);
    expect(find.text('陰時多雲'), findsOneWidget);
    expect(find.text(loadingLabel), findsNothing);
  });

  testWidgets('氣象資料：六類天氣各有自己的圖示，掃一眼就分得出來', (tester) async {
    // 七張卡在預設的測試視窗裡塞不下，而 ListView 不會建構捲出畫面的孩子。
    await tester.binding.setSurfaceSize(const Size(800, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // 分桶依據是官方分類代碼（Q11 1(a)），不是中文描述的關鍵字——所以這裡刻意
    // 讓描述全部相同，只有代碼不同：關鍵字比對的實作會在這一則上整排變成同一個圖示。
    await pumpDisplay(
      tester,
      repositoryAnswering(
        Future.value(
          ForecastAvailable([
            for (final code in const [1, 4, 8, 15, 24, 23, 40])
              slotFrom(
                18,
                description: '天氣',
                code: code,
                rain: 0,
                min: 20,
                max: 25,
                comfort: '舒適',
              ),
          ]),
        ),
      ),
    );

    await controllerOf(tester).search('臺北市');
    await tester.pump();

    expect(find.byIcon(Icons.wb_sunny), findsOneWidget, reason: '代碼 1：晴');
    expect(find.byIcon(Icons.cloud), findsOneWidget, reason: '代碼 4：多雲陰');
    expect(find.byIcon(Icons.umbrella), findsOneWidget, reason: '代碼 8：雨');
    expect(find.byIcon(Icons.thunderstorm), findsOneWidget, reason: '代碼 15：雷雨');
    expect(find.byIcon(Icons.foggy), findsOneWidget, reason: '代碼 24：霧');
    expect(find.byIcon(Icons.ac_unit), findsOneWidget, reason: '代碼 23：雪');
    expect(
      find.byIcon(Icons.help_outline),
      findsOneWidget,
      reason: '代碼 40 不在官方表內，退回中性圖示而不是讓整筆預報作廢',
    );
  });

  testWidgets('錯誤：重試沒有意義的失敗不給重試按鈕，並引導使用者去選建議', (tester) async {
    await pumpDisplay(tester, neverAnswers());

    await controllerOf(tester).search('火星');
    await tester.pump();

    expect(find.text('找不到「火星」，請從建議清單選擇縣市'), findsOneWidget);
    expect(find.text('重試'), findsNothing, reason: '按了也不會變好的按鈕只會讓人更困惑');
    expect(find.text(loadingLabel), findsNothing);
    expect(find.text('輸入縣市名稱，查詢今明 36 小時天氣'), findsNothing);
  });

  testWidgets('錯誤：連線失敗給重試按鈕，按下去重新查的是剛才那個縣市', (tester) async {
    var attempt = 0;
    final retried = Completer<ForecastResult>();
    final repository = MockForecastRepository();
    when(() => repository.fetchForecast('臺北市')).thenAnswer(
      (_) => attempt++ == 0
          ? Future.value(
              ForecastFailed(
                ConnectionFailure(
                  detail: 'connection timeout',
                  requestUri: anyUri,
                ),
              ),
            )
          : retried.future,
    );
    await pumpDisplay(tester, repository);

    await controllerOf(tester).search('台北');
    await tester.pump();
    expect(find.text('連線失敗，請檢查網路後重試'), findsOneWidget);

    await tester.tap(find.text('重試'));
    await tester.pump();
    expect(find.text(loadingLabel), findsOneWidget, reason: '重試也是一次查詢，同樣要走讀取中');

    retried.complete(ForecastAvailable(thirtySixHours));
    await tester.pumpAndSettle();
    // 使用者按重試時輸入框裡打的是什麼並不重要：重試重跑的是失敗的那一次查詢。
    expect(find.text('臺北市'), findsOneWidget);
    verify(() => repository.fetchForecast('臺北市')).called(2);
  });

  testWidgets('錯誤：診斷資訊預設收著，想看的人展開得到', (tester) async {
    await pumpDisplay(
      tester,
      repositoryAnswering(
        Future.value(
          ForecastFailed(
            InvalidToken(
              statusCode: 401,
              responseBody: 'Invalid authorization',
              requestUri: anyUri,
            ),
          ),
        ),
      ),
    );

    await controllerOf(tester).search('臺北市');
    await tester.pump();

    expect(find.text('授權碼無效，請更新後再試'), findsOneWidget, reason: '是憑證問題，不是網路');
    expect(
      find.textContaining('HTTP 401'),
      findsNothing,
      reason: '一般使用者不該預設被技術細節干擾',
    );

    await tester.tap(find.text('詳細資訊'));
    await tester.pumpAndSettle();

    expect(find.textContaining('HTTP 401'), findsOneWidget);
    // 授權碼走 header 而非查詢參數（Q27），所以請求網址可以原樣顯示。
    expect(find.textContaining(anyUri.toString()), findsOneWidget);
  });
}

/// 讀取中狀態的招牌文字：15 秒的逾時（Q18）需要一句話說明系統還在動。
const loadingLabel = '查詢中…';

Future<void> pumpDisplay(WidgetTester tester, ForecastRepository repository) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [forecastRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: Scaffold(body: ForecastDisplay())),
      ),
    );

/// 取得畫面上的 notifier，用來送出查詢。
ForecastController controllerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(ForecastDisplay)))
        .read(forecastControllerProvider.notifier);

ForecastRepository repositoryAnswering(Future<ForecastResult> result) {
  final repository = MockForecastRepository();
  when(() => repository.fetchForecast(any())).thenAnswer((_) => result);
  return repository;
}

/// 永遠不回應的上游：讓畫面停在讀取中，也證明初始狀態不會自己去查。
ForecastRepository neverAnswers() =>
    repositoryAnswering(Completer<ForecastResult>().future);

class MockForecastRepository extends Mock implements ForecastRepository {}

final anyUri = Uri.parse(
  'https://opendata.cwa.gov.tw/api/v1/rest/datastore/F-C0032-001',
);

/// 今明 36 小時：三段 12 小時，從今天傍晚一路排到後天早上。
///
/// 起訖時間以「今天的 00:00」為基準推算，而不是寫死日期——相對日的標籤本來就
/// 取決於今天是哪一天，寫死日期的測試明天就會紅。
final thirtySixHours = [
  slotFrom(
    18,
    description: '多雲時晴',
    code: 4,
    rain: 10,
    min: 27,
    max: 31,
    comfort: '悶熱',
  ),
  slotFrom(
    30,
    description: '午後短暫雷陣雨',
    code: 15,
    rain: 70,
    min: 26,
    max: 33,
    comfort: '易中暑',
  ),
  slotFrom(
    42,
    description: '陰時多雲',
    code: 7,
    rain: 20,
    min: 25,
    max: 29,
    comfort: '舒適',
  ),
];

ForecastSlot slotFrom(
  int startHourFromToday, {
  required String description,
  required int code,
  required int rain,
  required int min,
  required int max,
  required String comfort,
}) {
  final today = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  return ForecastSlot(
    startTime: today.add(Duration(hours: startHourFromToday)),
    endTime: today.add(Duration(hours: startHourFromToday + 12)),
    weatherDescription: description,
    weatherCode: code,
    rainProbability: rain,
    minTemperature: min,
    maxTemperature: max,
    comfort: comfort,
  );
}
