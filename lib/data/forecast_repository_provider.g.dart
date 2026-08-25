// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forecast_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 組裝真正的 repository。放在 data 層，是為了讓 [CwaApiClient] 這類上游細節
/// 不必被呈現層 import——呈現層看到的型別只有 [ForecastRepository]。
///
/// 這也是測試唯一需要覆寫的接縫：狀態機測試在這裡換上替身。（Q9）

@ProviderFor(forecastRepository)
final forecastRepositoryProvider = ForecastRepositoryProvider._();

/// 組裝真正的 repository。放在 data 層，是為了讓 [CwaApiClient] 這類上游細節
/// 不必被呈現層 import——呈現層看到的型別只有 [ForecastRepository]。
///
/// 這也是測試唯一需要覆寫的接縫：狀態機測試在這裡換上替身。（Q9）

final class ForecastRepositoryProvider
    extends
        $FunctionalProvider<
          ForecastRepository,
          ForecastRepository,
          ForecastRepository
        >
    with $Provider<ForecastRepository> {
  /// 組裝真正的 repository。放在 data 層，是為了讓 [CwaApiClient] 這類上游細節
  /// 不必被呈現層 import——呈現層看到的型別只有 [ForecastRepository]。
  ///
  /// 這也是測試唯一需要覆寫的接縫：狀態機測試在這裡換上替身。（Q9）
  ForecastRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forecastRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forecastRepositoryHash();

  @$internal
  @override
  $ProviderElement<ForecastRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ForecastRepository create(Ref ref) {
    return forecastRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForecastRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForecastRepository>(value),
    );
  }
}

String _$forecastRepositoryHash() =>
    r'89e8a76bb9cbc3fd3d4bfddb79431280f5c5032a';
