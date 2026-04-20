// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeController)
final themeControllerProvider = ThemeControllerProvider._();

final class ThemeControllerProvider
    extends $NotifierProvider<ThemeController, AppThemeMode> {
  ThemeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeControllerHash();

  @$internal
  @override
  ThemeController create() => ThemeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$themeControllerHash() => r'9353d394f6487ecb7e446022afd77a16ca20d098';

abstract class _$ThemeController extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeMode, AppThemeMode>,
              AppThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(materialTheme)
final materialThemeProvider = MaterialThemeProvider._();

final class MaterialThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  MaterialThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'materialThemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$materialThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return materialTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$materialThemeHash() => r'4ecc8726032129b316fd106e6e5e78a32d9bd9de';

@ProviderFor(fTheme)
final fThemeProvider = FThemeProvider._();

final class FThemeProvider
    extends $FunctionalProvider<FThemeData, FThemeData, FThemeData>
    with $Provider<FThemeData> {
  FThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fThemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fThemeHash();

  @$internal
  @override
  $ProviderElement<FThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FThemeData create(Ref ref) {
    return fTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FThemeData>(value),
    );
  }
}

String _$fThemeHash() => r'70e8fb043d0ce652402d17fff7b7b04d5d3a6fbc';
