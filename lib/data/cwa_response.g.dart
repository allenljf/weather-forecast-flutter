// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cwa_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CwaForecastResponse _$CwaForecastResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CwaForecastResponse', json, ($checkedConvert) {
      final val = CwaForecastResponse(
        records: $checkedConvert(
          'records',
          (v) => CwaRecords.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

CwaRecords _$CwaRecordsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CwaRecords', json, ($checkedConvert) {
      final val = CwaRecords(
        location: $checkedConvert(
          'location',
          (v) => (v as List<dynamic>)
              .map((e) => CwaLocation.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

CwaLocation _$CwaLocationFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CwaLocation', json, ($checkedConvert) {
      final val = CwaLocation(
        locationName: $checkedConvert('locationName', (v) => v as String),
        weatherElement: $checkedConvert(
          'weatherElement',
          (v) => (v as List<dynamic>)
              .map((e) => CwaWeatherElement.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

CwaWeatherElement _$CwaWeatherElementFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CwaWeatherElement', json, ($checkedConvert) {
      final val = CwaWeatherElement(
        elementName: $checkedConvert('elementName', (v) => v as String),
        time: $checkedConvert(
          'time',
          (v) => (v as List<dynamic>)
              .map((e) => CwaTimeSlot.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

CwaTimeSlot _$CwaTimeSlotFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CwaTimeSlot', json, ($checkedConvert) {
      final val = CwaTimeSlot(
        startTime: $checkedConvert('startTime', (v) => v as String),
        endTime: $checkedConvert('endTime', (v) => v as String),
        parameter: $checkedConvert(
          'parameter',
          (v) => CwaParameter.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

CwaParameter _$CwaParameterFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CwaParameter', json, ($checkedConvert) {
      final val = CwaParameter(
        parameterName: $checkedConvert('parameterName', (v) => v as String),
        parameterValue: $checkedConvert('parameterValue', (v) => v as String?),
      );
      return val;
    });
