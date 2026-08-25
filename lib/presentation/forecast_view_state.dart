import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';

/// 畫面狀態：顯示區塊在任一時刻所處的情況，恰好四種。（Q8(a)）
///
/// 刻意不用 Riverpod 的 `AsyncValue`：它是 sealed 但只有三個子型別，沒有
/// 「尚未開始」，而需求要四個 Widget（F15）。自訂 sealed 四態是唯一能讓四態
/// 收斂成單一 exhaustive `switch` 的做法。
///
/// 附帶效果：因為 notifier 的 `build()` 永不拋錯，Riverpod 3 的自動重試（F17）
/// 與 `ProviderException` 包裹（F18）在本專案完全碰不到。
sealed class ForecastViewState {
  const ForecastViewState();
}

/// 初始：使用者尚未送出任何查詢。
final class ForecastInitial extends ForecastViewState {
  const ForecastInitial();
}

/// 讀取中：查詢進行中。逾時放寬到 15 秒（Q18），所以這個狀態可能持續很久。
final class ForecastLoading extends ForecastViewState {
  const ForecastLoading();
}

/// 氣象資料：查詢成功且有資料可顯示。
final class ForecastData extends ForecastViewState {
  const ForecastData({required this.locationName, required this.slots});

  /// 這份資料是哪一個縣市的——使用者要能確認沒有查錯。
  final String locationName;

  /// 今明 36 小時的三個預報時段。
  final List<ForecastSlot> slots;
}

/// 錯誤：查詢未能產出可顯示的氣象資料。
///
/// 「查無資料」歸屬於這裡，不是第五種狀態——需求明定四個。（Q3）
final class ForecastError extends ForecastViewState {
  const ForecastError(this.failure);

  final Failure failure;
}
