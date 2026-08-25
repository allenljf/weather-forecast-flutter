import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/domain/weather_category.dart';

/// 期望值取自官方「預報產品天氣描述代碼表」（D0047.pdf，2026-08-25 取得），
/// 每一列附上該代碼底下的一句官方中文描述，作為分桶依據的證據。
/// 刻意不採用社群流傳的版本——它把不存在的代碼 40 也算了進去（F14）。
const _officialCodes = <int, (String, WeatherCategory)>{
  1: ('晴天', WeatherCategory.clear),
  2: ('晴時多雲', WeatherCategory.clear),
  3: ('多雲時晴', WeatherCategory.clear),
  4: ('多雲', WeatherCategory.cloudy),
  5: ('多雲時陰', WeatherCategory.cloudy),
  6: ('陰時多雲', WeatherCategory.cloudy),
  7: ('陰天', WeatherCategory.cloudy),
  8: ('短暫陣雨', WeatherCategory.rain),
  9: ('多雲時陰短暫雨', WeatherCategory.rain),
  10: ('陰時多雲短暫雨', WeatherCategory.rain),
  11: ('雨天', WeatherCategory.rain),
  12: ('多雲時陰有雨', WeatherCategory.rain),
  13: ('陰時多雲有雨', WeatherCategory.rain),
  14: ('陰有雨', WeatherCategory.rain),
  15: ('多雲雷陣雨', WeatherCategory.thunderstorm),
  16: ('多雲時陰雷陣雨', WeatherCategory.thunderstorm),
  17: ('陰時多雲雷陣雨', WeatherCategory.thunderstorm),
  18: ('陰雷陣雨', WeatherCategory.thunderstorm),
  19: ('晴午後多雲短暫陣雨', WeatherCategory.rain),
  20: ('多雲午後短暫陣雨', WeatherCategory.rain),
  21: ('晴午後雷陣雨', WeatherCategory.thunderstorm),
  22: ('多雲午後雷陣雨', WeatherCategory.thunderstorm),
  23: ('多雲短暫雨或雪', WeatherCategory.snow),
  24: ('晴有霧', WeatherCategory.fog),
  25: ('晴時多雲有霧', WeatherCategory.fog),
  26: ('多雲時晴有霧', WeatherCategory.fog),
  27: ('多雲有霧', WeatherCategory.fog),
  28: ('陰有霧', WeatherCategory.fog),
  29: ('多雲局部雨', WeatherCategory.rain),
  30: ('多雲時陰局部雨', WeatherCategory.rain),
  31: ('多雲有霧有局部雨', WeatherCategory.fog),
  32: ('多雲時陰有霧有陣雨', WeatherCategory.fog),
  33: ('多雲局部雷陣雨', WeatherCategory.thunderstorm),
  34: ('多雲時陰局部雷陣雨', WeatherCategory.thunderstorm),
  35: ('多雲有霧有雷陣雨', WeatherCategory.fog),
  36: ('多雲時陰有雷陣雨有霧', WeatherCategory.fog),
  37: ('多雲局部雨或雪有霧', WeatherCategory.snow),
  38: ('短暫雨有霧', WeatherCategory.fog),
  39: ('有雨有霧', WeatherCategory.fog),
  41: ('陣雨或雷雨有霧', WeatherCategory.fog),
  42: ('下雪', WeatherCategory.snow),
};

void main() {
  group('天氣分類', () {
    test('官方表的每一個代碼都落在它該去的分類', () {
      for (final MapEntry(key: code, value: (description, expected))
          in _officialCodes.entries) {
        expect(
          WeatherCategory.forCode(code),
          expected,
          reason: '代碼 $code（$description）',
        );
      }
    });

    test('期望表涵蓋官方的 41 個代碼——1 到 42 之間只缺 40', () {
      expect(_officialCodes.keys.toList()..sort(), [
        for (var code = 1; code <= 42; code++)
          if (code != 40) code,
      ]);
    });

    test('代碼 40 不在官方表內，沒有分類', () {
      expect(WeatherCategory.forCode(40), isNull);
    });

    test('官方表以外的代碼沒有分類', () {
      expect(WeatherCategory.forCode(0), isNull);
      expect(WeatherCategory.forCode(43), isNull);
      expect(WeatherCategory.forCode(-1), isNull);
    });
  });
}
