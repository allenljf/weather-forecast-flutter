import 'package:weather_forecast/data/cwa_response.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';

const _requiredElements = ['Wx', 'PoP', 'MinT', 'MaxT', 'CI'];

/// 嚴格解析單一縣市的預報：五個天氣要素缺任一、或數值轉型失敗，
/// 即判定為格式錯誤，一律以 [FormatException] 表達。（Q23(i)）
///
/// 實測顯示正常情況下 330 個 parameter 零缺失（F30），因此缺失代表異常，
/// 而偵測異常正是需求要求展示的能力；寬鬆解析會讓那條需求永遠無法被示範。
///
/// 上游回空陣列時回傳空清單——那不是格式錯誤，而是「上游查無此縣市」，
/// 由 repository 判斷（#7）。
List<ForecastSlot> parseForecastSlots(
  Map<String, dynamic> json, {
  required String locationName,
}) {
  final locations = CwaForecastResponse.fromJson(json).records.location;
  if (locations.isEmpty) return const [];

  // 依 locationName 查找而非取 [0]：上游的 location 順序不是 enum 順序（F28），
  // 而依索引取值的錯誤是靜默的。
  final location = _firstWhereOrNull(
    locations,
    (candidate) => candidate.locationName == locationName,
  );
  if (location == null) {
    throw FormatException(
      '回應中沒有「$locationName」，只有 ${locations.map((l) => l.locationName)}',
    );
  }

  final elements = <String, CwaWeatherElement>{
    for (final element in location.weatherElement) element.elementName: element,
  };
  for (final name in _requiredElements) {
    if (!elements.containsKey(name)) {
      throw FormatException('「$locationName」缺少天氣要素 $name');
    }
  }

  return [for (final slot in elements['Wx']!.time) _slotFrom(slot, elements)];
}

/// 以天氣現象的時段為主軸，其餘要素**依起始時間對齊**。
///
/// 同樣不依索引：要素之間若有一格錯位，依索引取值只會安靜地把降雨機率
/// 接到別的時段上。
ForecastSlot _slotFrom(
  CwaTimeSlot wx,
  Map<String, CwaWeatherElement> elements,
) {
  CwaParameter parameterOf(String elementName) {
    final slot = _firstWhereOrNull(
      elements[elementName]!.time,
      (candidate) => candidate.startTime == wx.startTime,
    );
    if (slot == null) {
      throw FormatException('天氣要素 $elementName 沒有 ${wx.startTime} 起的時段');
    }
    return slot.parameter;
  }

  final weatherCode = wx.parameter.parameterValue;
  if (weatherCode == null) {
    throw FormatException('${wx.startTime} 起的天氣現象缺少天氣分類代碼');
  }

  return ForecastSlot(
    startTime: _time(wx.startTime),
    endTime: _time(wx.endTime),
    weatherDescription: wx.parameter.parameterName,
    weatherCode: _integer(weatherCode, '天氣分類代碼'),
    rainProbability: _integer(parameterOf('PoP').parameterName, '降雨機率'),
    minTemperature: _integer(parameterOf('MinT').parameterName, '最低溫度'),
    maxTemperature: _integer(parameterOf('MaxT').parameterName, '最高溫度'),
    comfort: parameterOf('CI').parameterName,
  );
}

int _integer(String raw, String label) {
  final value = int.tryParse(raw);
  if (value == null) throw FormatException('$label 不是整數：「$raw」');
  return value;
}

DateTime _time(String raw) {
  final value = DateTime.tryParse(raw);
  if (value == null) throw FormatException('時間格式無法解析：「$raw」');
  return value;
}

T? _firstWhereOrNull<T>(List<T> items, bool Function(T) matches) {
  for (final item in items) {
    if (matches(item)) return item;
  }
  return null;
}
