import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vsync/core/services/service_layer.dart';
import 'package:vsync/src/api/vtop/types.dart';
import 'package:flutter/foundation.dart';

part 'course_hub_provider.g.dart';

@immutable
class CourseHubState {
  final List<CourseOption> courses;
  final List<SlotOption> slots;
  final List<CourseClassEntry> classEntries;
  final CoursePageDetail? selectedCourseDetail;
  final String? selectedCourseValue;
  final String? selectedSlotValue;
  final bool isLoading;
  final String? searchQuery;

  const CourseHubState({
    this.courses = const [],
    this.slots = const [],
    this.classEntries = const [],
    this.selectedCourseDetail,
    this.selectedCourseValue,
    this.selectedSlotValue,
    this.isLoading = false,
    this.searchQuery,
  });

  CourseHubState copyWith({
    List<CourseOption>? courses,
    List<SlotOption>? slots,
    List<CourseClassEntry>? classEntries,
    CoursePageDetail? selectedCourseDetail,
    String? selectedCourseValue,
    String? selectedSlotValue,
    bool? isLoading,
    String? searchQuery,
  }) {
    return CourseHubState(
      courses: courses ?? this.courses,
      slots: slots ?? this.slots,
      classEntries: classEntries ?? this.classEntries,
      selectedCourseDetail: selectedCourseDetail ?? this.selectedCourseDetail,
      selectedCourseValue: selectedCourseValue ?? this.selectedCourseValue,
      selectedSlotValue: selectedSlotValue ?? this.selectedSlotValue,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<CourseOption> get filteredCourses {
    if (searchQuery == null || searchQuery!.isEmpty) return courses;
    final q = searchQuery!.toLowerCase();
    return courses.where((c) => 
      c.courseCode.toLowerCase().contains(q) || 
      c.courseTitle.toLowerCase().contains(q)
    ).toList();
  }
}

@riverpod
class CourseHubNotifier extends _$CourseHubNotifier {
  @override
  CourseHubState build() {
    return const CourseHubState();
  }

  Future<void> fetchCourses({bool refresh = false}) async {
    state = state.copyWith(isLoading: true);
    try {
      final services = await ref.read(appServicesProvider.future);
      final response = await services.vtopDataRepository.loadCoursesForCoursePage(refresh: refresh);
      state = state.copyWith(
        courses: response.courses,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> selectCourse(String courseValue) async {
    state = state.copyWith(
      selectedCourseValue: courseValue,
      isLoading: true,
      slots: [],
      classEntries: [],
      selectedCourseDetail: null,
    );
    
    try {
      final services = await ref.read(appServicesProvider.future);
      final account = await services.authRepository.loadActiveAccount();
      if (account == null) return;

      final response = await services.vtopDataRepository.loadSlotsForCoursePage(
        semesterId: account.identity.selectedSemesterId,
        courseId: courseValue,
      );
      
      state = state.copyWith(
        slots: response.slots,
        classEntries: response.classEntries,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> fetchCourseDetail(CourseClassEntry entry) async {
    state = state.copyWith(isLoading: true, selectedCourseDetail: null);
    try {
      final services = await ref.read(appServicesProvider.future);
      final detail = await services.vtopDataRepository.loadCourseDetail(
        semesterId: entry.semesterId,
        erpId: entry.erpId,
        classId: entry.classId,
      );
      
      state = state.copyWith(
        selectedCourseDetail: detail,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<List<int>> downloadMaterial(String path) async {
    final services = await ref.read(appServicesProvider.future);
    final client = await services.sessionCoordinator.ensureAuthenticated(
      account: (await services.authRepository.loadActiveAccount())!,
      password: await services.authRepository.requirePassword(),
    );
    return services.gateway.downloadCourseMaterial(client: client, downloadPath: path);
  }
}
