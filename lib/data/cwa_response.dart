import 'package:json_annotation/json_annotation.dart';

part 'cwa_response.g.dart';

/// 上游回應的忠實映射：這幾個類別存在的唯一目的，是把 API 的怪異形狀
/// 擋在 `data` 層以內，不讓它洩漏到領域模型與畫面。（Q23(b)）
///
/// 刻意不讀 `success`：它是字串 `"true"` 而非布林，而且上游對不存在的縣市
/// 照樣回 `"true"`（F11），對正確性零貢獻。
@JsonSerializable(createFactory: true, createToJson: false, checked: true)
class CwaForecastResponse {
  const CwaForecastResponse({required this.records});

  factory CwaForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$CwaForecastResponseFromJson(json);

  final CwaRecords records;
}

@JsonSerializable(createFactory: true, createToJson: false, checked: true)
class CwaRecords {
  const CwaRecords({required this.location});

  factory CwaRecords.fromJson(Map<String, dynamic> json) =>
      _$CwaRecordsFromJson(json);

  final List<CwaLocation> location;
}

@JsonSerializable(createFactory: true, createToJson: false, checked: true)
class CwaLocation {
  const CwaLocation({required this.locationName, required this.weatherElement});

  factory CwaLocation.fromJson(Map<String, dynamic> json) =>
      _$CwaLocationFromJson(json);

  final String locationName;

  final List<CwaWeatherElement> weatherElement;
}

@JsonSerializable(createFactory: true, createToJson: false, checked: true)
class CwaWeatherElement {
  const CwaWeatherElement({required this.elementName, required this.time});

  factory CwaWeatherElement.fromJson(Map<String, dynamic> json) =>
      _$CwaWeatherElementFromJson(json);

  final String elementName;

  final List<CwaTimeSlot> time;
}

@JsonSerializable(createFactory: true, createToJson: false, checked: true)
class CwaTimeSlot {
  const CwaTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.parameter,
  });

  factory CwaTimeSlot.fromJson(Map<String, dynamic> json) =>
      _$CwaTimeSlotFromJson(json);

  final String startTime;
  final String endTime;
  final CwaParameter parameter;
}

/// `parameter` 的鍵組成因要素而異（F29）：`Wx` 有 `parameterValue` 沒有單位，
/// `PoP`/`MinT`/`MaxT` 有單位沒有 value，`CI` 兩者皆無。數值一律是**字串**，
/// 而且藏在名為 `parameterName` 的欄位裡。單位本專案用不到，不映射。
@JsonSerializable(createFactory: true, createToJson: false, checked: true)
class CwaParameter {
  const CwaParameter({required this.parameterName, this.parameterValue});

  factory CwaParameter.fromJson(Map<String, dynamic> json) =>
      _$CwaParameterFromJson(json);

  final String parameterName;
  final String? parameterValue;
}
