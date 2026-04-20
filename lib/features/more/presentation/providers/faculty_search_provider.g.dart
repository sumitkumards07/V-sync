// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'faculty_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FacultySearch)
final facultySearchProvider = FacultySearchProvider._();

final class FacultySearchProvider
    extends $NotifierProvider<FacultySearch, FacultySearchState> {
  FacultySearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'facultySearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$facultySearchHash();

  @$internal
  @override
  FacultySearch create() => FacultySearch();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FacultySearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FacultySearchState>(value),
    );
  }
}

String _$facultySearchHash() => r'e57b445f9fc2ba2e843fd3b0033750a4a5ad410c';

abstract class _$FacultySearch extends $Notifier<FacultySearchState> {
  FacultySearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FacultySearchState, FacultySearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FacultySearchState, FacultySearchState>,
              FacultySearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
