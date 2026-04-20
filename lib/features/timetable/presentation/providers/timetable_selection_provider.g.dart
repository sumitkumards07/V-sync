// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimetableDaySelection)
final timetableDaySelectionProvider = TimetableDaySelectionProvider._();

final class TimetableDaySelectionProvider
    extends $NotifierProvider<TimetableDaySelection, int> {
  TimetableDaySelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timetableDaySelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timetableDaySelectionHash();

  @$internal
  @override
  TimetableDaySelection create() => TimetableDaySelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$timetableDaySelectionHash() =>
    r'12eb7d523da024083155728d4b849a9851022db0';

abstract class _$TimetableDaySelection extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
