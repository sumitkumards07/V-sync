// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_hub_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CourseHubNotifier)
final courseHubProvider = CourseHubNotifierProvider._();

final class CourseHubNotifierProvider
    extends $NotifierProvider<CourseHubNotifier, CourseHubState> {
  CourseHubNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'courseHubProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$courseHubNotifierHash();

  @$internal
  @override
  CourseHubNotifier create() => CourseHubNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CourseHubState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CourseHubState>(value),
    );
  }
}

String _$courseHubNotifierHash() => r'e1e1ab3268398d6879cf2499da654ffb0663b279';

abstract class _$CourseHubNotifier extends $Notifier<CourseHubState> {
  CourseHubState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CourseHubState, CourseHubState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CourseHubState, CourseHubState>,
              CourseHubState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
