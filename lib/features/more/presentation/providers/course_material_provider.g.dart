// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_material_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CourseMaterialNotifier)
final courseMaterialProvider = CourseMaterialNotifierProvider._();

final class CourseMaterialNotifierProvider
    extends $NotifierProvider<CourseMaterialNotifier, CourseMaterialState> {
  CourseMaterialNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseMaterialProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseMaterialNotifierHash();

  @$internal
  @override
  CourseMaterialNotifier create() => CourseMaterialNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseMaterialState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseMaterialState>(value),
    );
  }
}

String _$courseMaterialNotifierHash() =>
    r'e35b3c166485e06d3d3da27d6c22dbf75d7f9cd7';

abstract class _$CourseMaterialNotifier extends $Notifier<CourseMaterialState> {
  CourseMaterialState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CourseMaterialState, CourseMaterialState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CourseMaterialState, CourseMaterialState>,
              CourseMaterialState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
