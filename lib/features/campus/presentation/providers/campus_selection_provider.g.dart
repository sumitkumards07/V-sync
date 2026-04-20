// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campus_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CampusDateSelection)
final campusDateSelectionProvider = CampusDateSelectionProvider._();

final class CampusDateSelectionProvider
    extends $NotifierProvider<CampusDateSelection, DateTime> {
  CampusDateSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'campusDateSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$campusDateSelectionHash();

  @$internal
  @override
  CampusDateSelection create() => CampusDateSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$campusDateSelectionHash() =>
    r'1b2363a934d3bc2e10c43b4a8cb7bdcb38d5d444';

abstract class _$CampusDateSelection extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
