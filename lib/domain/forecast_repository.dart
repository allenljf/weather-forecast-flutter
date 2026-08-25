import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';

/// 上層取得預報的唯一入口，也是測試替身的邊界。（Q9）
///
/// 介面留在 domain、實作放在 data，是為了讓「上層只看得到領域模型或失敗」
/// 這件事由型別系統保證，而不是靠慣例：Dio、HTTP 回應與 JSON 都表達不出來。
///
/// 刻意不做 use case 層：只有一個端點、一次呼叫，那一層會是純轉發。
abstract interface class ForecastRepository {
  /// 查詢一個縣市的今明 36 小時預報。
  ///
  /// **永不拋出例外**：所有失敗都走 [ForecastFailed] 回傳。這讓上層能以單一
  /// exhaustive switch 收斂四態（Q8），也讓 Riverpod 3 的自動重試（F17）與
  /// 例外包裹（F18）在本專案完全碰不到。
  Future<ForecastResult> fetchForecast(String locationName);
}

/// 一次查詢的結果：要嘛是預報時段，要嘛是一個已經分類好的失敗。
sealed class ForecastResult {
  const ForecastResult();
}

/// 查到了：今明 36 小時的三個預報時段。
final class ForecastAvailable extends ForecastResult {
  const ForecastAvailable(this.slots);

  final List<ForecastSlot> slots;
}

/// 沒查到：附上六種失敗中的哪一種，由呈現層決定文案與是否給重試。
final class ForecastFailed extends ForecastResult {
  const ForecastFailed(this.failure);

  final Failure failure;
}
