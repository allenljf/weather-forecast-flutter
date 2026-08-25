import 'package:weather_forecast/data/cwa_api_client.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_repository.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';

/// [ForecastRepository] 以中央氣象署為來源的實作。
class CwaForecastRepository implements ForecastRepository {
  const CwaForecastRepository(this._client);

  final CwaApiClient _client;

  @override
  Future<ForecastResult> fetchForecast(String locationName) async {
    final List<ForecastSlot> slots;
    try {
      slots = await _client.fetchForecast(locationName);
    } on CwaApiException catch (error) {
      // 這裡是例外的終點：往上只走回傳值，資料層的例外型別不外洩。
      return ForecastFailed(error.failure);
    }

    if (slots.isEmpty) {
      return ForecastFailed(
        UpstreamMissingLocation(
          locationName: locationName,
          requestUri: CwaApiClient.requestUriFor(locationName),
        ),
      );
    }
    return ForecastAvailable(slots);
  }
}
