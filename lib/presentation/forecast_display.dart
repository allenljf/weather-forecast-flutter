import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_forecast/domain/failure.dart';
import 'package:weather_forecast/domain/forecast_slot.dart';
import 'package:weather_forecast/domain/relative_day.dart';
import 'package:weather_forecast/domain/weather_category.dart';
import 'package:weather_forecast/presentation/forecast_controller.dart';
import 'package:weather_forecast/presentation/forecast_view_state.dart';

/// 顯示區塊：需求明定的四個狀態各有一個 widget，這裡是它們唯一的分派點。（#10）
///
/// 分派用無 default 分支的 switch，所以四態少一個、或有人偷加第五個，都是編譯錯誤。
class ForecastDisplay extends ConsumerWidget {
  const ForecastDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forecastControllerProvider);
    return switch (state) {
      ForecastInitial() => const _InitialView(),
      ForecastLoading() => const _LoadingView(),
      ForecastData(:final locationName, :final slots) => _DataView(
        locationName: locationName,
        slots: slots,
      ),
      ForecastError(:final failure) => _ErrorView(
        failure: failure,
        onRetry: () =>
            unawaited(ref.read(forecastControllerProvider.notifier).retry()),
      ),
    };
  }
}

/// 初始：空白畫面對第一次開啟的人是零資訊，所以給圖示加一句該做什麼。（Q35 1(b)）
class _InitialView extends StatelessWidget {
  const _InitialView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 48),
          SizedBox(height: 16),
          Text('輸入縣市名稱，查詢今明 36 小時天氣'),
        ],
      ),
    );
  }
}

/// 讀取中：逾時放寬到 15 秒（Q18），光是一個轉圈的圖示看久了會像當掉，
/// 所以配一句文字。inline 而非 Dialog——需求明文。（Q35 2(b)）
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('查詢中…'),
        ],
      ),
    );
  }
}

/// 氣象資料：三個時段全列，對得上題目名稱裡的 36 小時。（Q4(b)）
class _DataView extends StatelessWidget {
  const _DataView({required this.locationName, required this.slots});

  final String locationName;
  final List<ForecastSlot> slots;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(locationName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        for (final slot in slots) _SlotCard(slot: slot),
      ],
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});

  final ForecastSlot slot;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${formatRelativeDayTime(slot.startTime, now: now)} ～ '
              '${formatRelativeDayTime(slot.endTime, now: now)}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(_iconFor(slot.category), size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slot.weatherDescription,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        '${slot.minTemperature}°C ～ ${slot.maxTemperature}°C',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('降雨機率 ${slot.rainProbability}%'),
            Text('舒適度 ${slot.comfort}'),
          ],
        ),
      ),
    );
  }
}

/// 六類各一個內建圖示，不做日夜變體、不引外部素材。（Q11 3(a)/4）
/// 代碼不在官方表內時 [ForecastSlot.category] 回 `null`，這裡退回中性圖示——
/// 預報其他四個要素都好好的，沒理由因為一個圖示沒收錄就不給看。
IconData _iconFor(WeatherCategory? category) => switch (category) {
  WeatherCategory.clear => Icons.wb_sunny,
  WeatherCategory.cloudy => Icons.cloud,
  WeatherCategory.rain => Icons.umbrella,
  WeatherCategory.thunderstorm => Icons.thunderstorm,
  WeatherCategory.fog => Icons.foggy,
  WeatherCategory.snow => Icons.ac_unit,
  null => Icons.help_outline,
};

/// 錯誤：六種失敗各說各的話——否則那套分類在畫面上不產生任何可見價值。（Q20 1(a)）
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.failure, required this.onRetry});

  final Failure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final copy = failureCopy(failure);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 16),
          Text(
            copy.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          // 重試按鈕只在重試有意義的失敗上出現——否則使用者只是白按。（Q20 1(a)）
          if (copy.canRetry) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重試'),
            ),
          ],
          const SizedBox(height: 24),
          // 技術細節預設收合：有技術背景的人要判斷問題在哪，一般使用者不必被干擾。
          // （Q20 2(b)）
          ExpansionTile(
            title: const Text('詳細資訊'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(failure.diagnostics),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
