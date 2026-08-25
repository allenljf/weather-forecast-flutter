import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/presentation/forecast_view_state.dart';

/// 驗收條件：實作中不得出現 `AsyncValue`。（#8／Q8(a)）
///
/// 它只有三個子型別、沒有「尚未開始」（F15），一旦混進來，四態就會被偷偷降成
/// 三態，而且畫面上要到最後才看得出來。這條界線只有掃描原始碼守得住。
void main() {
  test('四態恰好四種，使用端可用無 default 分支的 switch 窮舉', () {
    const states = <ForecastViewState>[
      ForecastInitial(),
      ForecastLoading(),
      ForecastData(locationName: '臺北市', slots: []),
      ForecastError(InvalidQuery(query: '火星')),
    ];

    // 少列一種就編譯不過；多一種第五態也會逼這裡一起改。
    final names = [
      for (final state in states)
        switch (state) {
          ForecastInitial() => '初始',
          ForecastLoading() => '讀取中',
          ForecastData() => '氣象資料',
          ForecastError() => '錯誤',
        },
    ];

    expect(names, ['初始', '讀取中', '氣象資料', '錯誤']);
  });

  test('lib 底下沒有任何地方用到 AsyncValue', () {
    // 註解行不算：解釋「為什麼不用它」的那段話本身也提到這個名字。
    final comment = RegExp(r'^\s*(///?|\*)');
    final offenders = [
      for (final source
          in Directory('lib')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart')))
        for (final line in source.readAsLinesSync())
          if (line.contains('AsyncValue') && !comment.hasMatch(line))
            '${source.path}: ${line.trim()}',
    ];

    expect(offenders, isEmpty);
  });
}
