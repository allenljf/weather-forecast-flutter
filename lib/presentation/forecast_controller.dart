import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_forecast/data/forecast_repository_provider.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_repository.dart';
import 'package:weather_forecast/domain/location.dart';
import 'package:weather_forecast/presentation/forecast_view_state.dart';

part 'forecast_controller.g.dart';

/// 驅動顯示區塊的四態狀態機。（Q8(a)、Q18(b)）
@riverpod
class ForecastController extends _$ForecastController {
  /// 最後一次送出的請求序號。單調遞增，晚到的舊回應靠它認出自己已經過期。
  ///
  /// 刻意不靠「讀取中就停用確認鈕」來避免競態：那種正確性依賴 UI 記得停用，
  /// 無法被單元測試覆蓋。（Q18(b)）
  var _latestRequest = 0;

  @override
  ForecastViewState build() => const ForecastInitial();

  /// 送出一次查詢：正規化 → 命中才呼叫 repository → 指派狀態。
  Future<void> search(String query) async {
    final requestId = ++_latestRequest;
    final locationName = normaliseQuery(query);
    if (locationName == null) {
      // 上游對錯誤輸入完全靜默（F11），所以無效查詢在本地就結束、不發出請求。
      state = ForecastError(InvalidQuery(query: query));
      return;
    }

    state = const ForecastLoading();

    final result = await ref
        .read(forecastRepositoryProvider)
        .fetchForecast(locationName);

    // 期間又送出過查詢，這一份回應已經沒有人在等了。
    if (requestId != _latestRequest) return;

    state = switch (result) {
      ForecastAvailable(:final slots) => ForecastData(
        locationName: locationName,
        slots: slots,
      ),
      ForecastFailed(:final failure) => ForecastError(failure),
    };
  }
}
