import 'package:weather_forecast/domain/weather_category.dart';

/// 預報時段：一段有明確起訖時間的預報區間，今明 36 小時預報恆為三段。
///
/// 三段長度不相等：第一段只涵蓋當前 12 小時區塊的剩餘時間，不得從段序推算時間。（F47）
///
/// 這是 API 的鬆散結構在本專案的終點：上游把數值以字串藏在名為「名稱」的欄位裡、
/// 每個要素的鍵組成又各不相同（F29），那些形狀一律擋在 data 層以內，
/// 不得以 `parameterName` 之類的詞彙洩漏到這裡。（Q23）
class ForecastSlot {
  const ForecastSlot({
    required this.startTime,
    required this.endTime,
    required this.weatherDescription,
    required this.weatherCode,
    required this.rainProbability,
    required this.minTemperature,
    required this.maxTemperature,
    required this.comfort,
  });

  final DateTime startTime;
  final DateTime endTime;

  /// 天氣現象的中文描述，例如「多雲時晴」。
  final String weatherDescription;

  /// 氣象署替 [weatherDescription] 指定的天氣分類代碼。
  final int weatherCode;

  /// 降雨機率，百分比。
  final int rainProbability;

  /// 最低溫度，攝氏。
  final int minTemperature;

  /// 最高溫度，攝氏。
  final int maxTemperature;

  /// 舒適度描述，例如「舒適」。
  final String comfort;

  WeatherCategory? get category => WeatherCategory.forCode(weatherCode);

  @override
  bool operator ==(Object other) =>
      other is ForecastSlot &&
      other.startTime == startTime &&
      other.endTime == endTime &&
      other.weatherDescription == weatherDescription &&
      other.weatherCode == weatherCode &&
      other.rainProbability == rainProbability &&
      other.minTemperature == minTemperature &&
      other.maxTemperature == maxTemperature &&
      other.comfort == comfort;

  @override
  int get hashCode => Object.hash(
    startTime,
    endTime,
    weatherDescription,
    weatherCode,
    rainProbability,
    minTemperature,
    maxTemperature,
    comfort,
  );

  @override
  String toString() =>
      'ForecastSlot($startTime~$endTime, $weatherDescription($weatherCode), '
      '降雨 $rainProbability%, $minTemperature~$maxTemperature°C, $comfort)';
}
