// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 驅動顯示區塊的四態狀態機。（Q8(a)、Q18(b)）

@ProviderFor(ForecastController)
final forecastControllerProvider = ForecastControllerProvider._();

/// 驅動顯示區塊的四態狀態機。（Q8(a)、Q18(b)）
final class ForecastControllerProvider
    extends $NotifierProvider<ForecastController, ForecastViewState> {
  /// 驅動顯示區塊的四態狀態機。（Q8(a)、Q18(b)）
  ForecastControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forecastControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forecastControllerHash();

  @$internal
  @override
  ForecastController create() => ForecastController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForecastViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForecastViewState>(value),
    );
  }
}

String _$forecastControllerHash() =>
    r'4c5b140c67bc24fa586d680e014c593c43f59adc';

/// 驅動顯示區塊的四態狀態機。（Q8(a)、Q18(b)）

abstract class _$ForecastController extends $Notifier<ForecastViewState> {
  ForecastViewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ForecastViewState, ForecastViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForecastViewState, ForecastViewState>,
              ForecastViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
