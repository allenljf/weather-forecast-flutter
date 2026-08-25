import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weather_forecast/core/app_config.dart';
import 'package:weather_forecast/data/cwa_api_client.dart';
import 'package:weather_forecast/data/cwa_forecast_repository.dart';
import 'package:weather_forecast/domain/forecast_repository.dart';

part 'forecast_repository_provider.g.dart';

/// 組裝真正的 repository。放在 data 層，是為了讓 [CwaApiClient] 這類上游細節
/// 不必被呈現層 import——呈現層看到的型別只有 [ForecastRepository]。
///
/// 這也是測試唯一需要覆寫的接縫：狀態機測試在這裡換上替身。（Q9）
@Riverpod(keepAlive: true)
ForecastRepository forecastRepository(Ref ref) =>
    CwaForecastRepository(CwaApiClient(token: AppConfig.weatherApiToken));
