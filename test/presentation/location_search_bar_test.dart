import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_forecast/data/forecast_repository_provider.dart';
import 'package:weather_forecast/domain/forecast_repository.dart';
import 'package:weather_forecast/presentation/weather_app.dart';

/// 搜尋列：接縫 1（查詢正規化）與接縫 5（四態狀態機）在畫面上的會合處。（#9／#14）
///
/// 兩條接縫本身各自有自己的單元測試，所以這裡不重測比對規則、也不重測狀態轉移；
/// 這裡問的是使用者實際做得到什麼：打字之後看到什麼、按下去之後畫面變成什麼。
/// 觀察一律落在**顯示出來的文字**上，不觸碰 widget 的內部欄位。
void main() {
  testWidgets('輸入框是空的時候，「確認」按不下去——還沒輸入不是一次失敗的查詢', (tester) async {
    final repository = neverAnswers();
    await pumpApp(tester, repository);

    await tester.tap(find.text('確認'));
    await tester.pump();

    expect(
      find.text(initialLabel),
      findsOneWidget,
      reason: '空輸入不該進錯誤畫面，也不該進讀取中',
    );
    verifyNever(() => repository.fetchForecast(any()));
  });

  testWidgets('打一個「北」就列出臺北市與新北市——不必先知道官方怎麼寫', (tester) async {
    await pumpApp(tester, neverAnswers());

    expect(find.text('臺北市'), findsNothing, reason: '一個字都還沒打，不該有建議');

    await tester.enterText(find.byType(TextField), '北');
    await tester.pump();

    expect(find.text('臺北市'), findsOneWidget);
    expect(find.text('新北市'), findsOneWidget);
    expect(find.text('臺南市'), findsNothing, reason: '只列符合的，不是列出全部 22 個');
  });

  testWidgets('點選建議只把名稱填進輸入框並收起清單，查詢仍然要由使用者按確認', (tester) async {
    final repository = neverAnswers();
    await pumpApp(tester, repository);

    await tester.enterText(find.byType(TextField), '北');
    await tester.pump();
    await tester.tap(find.text('臺北市'));
    await tester.pump();

    expect(
      find.widgetWithText(TextField, '臺北市'),
      findsOneWidget,
      reason: '選了就不必再手打完整名稱',
    );
    expect(find.text('新北市'), findsNothing, reason: '選好了，清單該讓開');
    expect(
      find.text(initialLabel),
      findsOneWidget,
      reason: '選錯了還要有機會改，所以點選不等於送出',
    );
    verifyNever(() => repository.fetchForecast(any()));
  });

  testWidgets('打了對不上任何縣市的字按確認，會被明確告知輸入無效', (tester) async {
    final repository = neverAnswers();
    await pumpApp(tester, repository);

    await tester.enterText(find.byType(TextField), '火星');
    await tester.pump();
    await tester.tap(find.text('確認'));
    await tester.pump();

    expect(find.text('找不到「火星」，請從建議清單選擇縣市'), findsOneWidget);
    // 上游對錯誤輸入完全靜默（F11），所以這條路徑必須在本地就結束。
    verifyNever(() => repository.fetchForecast(any()));
  });

  test('全專案沒有 hooks 依賴', () {
    // 需求明文禁用 hooks（Q5）。`hooks_riverpod` 跟 `flutter_riverpod` 用起來
    // 幾乎一樣，哪天有人為了少寫一個 State class 順手換掉不會有人察覺——
    // 鎖定檔是傳遞依賴的權威來源，這條線只有掃描守得住。
    expect(File('pubspec.lock').readAsStringSync(), isNot(contains('hooks')));
  });
}

/// 初始狀態的招牌文字：用它判定畫面還停在「什麼都還沒查」。
const initialLabel = '輸入縣市名稱，查詢今明 36 小時天氣';

Future<void> pumpApp(WidgetTester tester, ForecastRepository repository) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [forecastRepositoryProvider.overrideWithValue(repository)],
        child: const WeatherApp(),
      ),
    );

/// 永遠不回應的上游：畫面會停在讀取中，所以「有沒有送出查詢」看得一清二楚。
ForecastRepository neverAnswers() {
  final repository = MockForecastRepository();
  when(() => repository.fetchForecast(any()))
      .thenAnswer((_) => Completer<ForecastResult>().future);
  return repository;
}

class MockForecastRepository extends Mock implements ForecastRepository {}
