import 'package:flutter_test/flutter_test.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';
import 'package:weather_forecast/domain/weather_category.dart';

ForecastSlot slotWithWeatherCode(int code) => ForecastSlot(
  startTime: DateTime(2026, 8, 25, 6),
  endTime: DateTime(2026, 8, 25, 18),
  weatherDescription: '陰短暫陣雨',
  weatherCode: code,
  rainProbability: 70,
  minTemperature: 26,
  maxTemperature: 31,
  comfort: '舒適至悶熱',
);

void main() {
  group('預報時段', () {
    test('天氣分類由天氣分類代碼決定', () {
      expect(slotWithWeatherCode(11).category, WeatherCategory.rain);
    });

    test('天氣分類代碼不在官方表內時沒有分類', () {
      expect(slotWithWeatherCode(40).category, isNull);
    });

    test('欄位相同的兩個時段相等——上層可以直接拿整個時段做斷言', () {
      expect(slotWithWeatherCode(11), slotWithWeatherCode(11));
      expect(
        slotWithWeatherCode(11).hashCode,
        slotWithWeatherCode(11).hashCode,
      );
    });

    test('任何一個欄位不同就不相等', () {
      expect(slotWithWeatherCode(11), isNot(slotWithWeatherCode(12)));
    });
  });
}
