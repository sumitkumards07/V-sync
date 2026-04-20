import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vsync/core/utils/entity/course_material.dart';

part 'course_material_provider.g.dart';

class CourseMaterialState {
  final List<CourseModule> modules;
  final bool isLoading;
  final String? selectedCourseCode;

  CourseMaterialState({
    required this.modules,
    this.isLoading = false,
    this.selectedCourseCode,
  });

  CourseMaterialState copyWith({
    List<CourseModule>? modules,
    bool? isLoading,
    String? selectedCourseCode,
  }) {
    return CourseMaterialState(
      modules: modules ?? this.modules,
      isLoading: isLoading ?? this.isLoading,
      selectedCourseCode: selectedCourseCode ?? this.selectedCourseCode,
    );
  }
}

@riverpod
class CourseMaterialNotifier extends _$CourseMaterialNotifier {
  @override
  CourseMaterialState build() {
    return CourseMaterialState(
      modules: _getMockModules(),
      selectedCourseCode: "CHY1009",
    );
  }

  void selectCourse(String courseCode) {
    state = state.copyWith(selectedCourseCode: courseCode);
    // In a real app, this would trigger a fetch
  }

  List<CourseModule> _getMockModules() {
    return [
      const CourseModule(
        moduleName: "Module 1: Chemical Bonding",
        materials: [
          CourseMaterial(
            title: "Crystal Field Theory - Part 1",
            uploadDate: "12 Mar 2024",
            fileType: "PDF",
            fileSize: "2.4 MB",
            downloadUrl: "#",
          ),
          CourseMaterial(
            title: "Molecular Orbital Diagrams",
            uploadDate: "15 Mar 2024",
            fileType: "PPT",
            fileSize: "8.1 MB",
            downloadUrl: "#",
          ),
        ],
      ),
      const CourseModule(
        moduleName: "Module 2: Water Technology",
        materials: [
          CourseMaterial(
            title: "Hardness of Water - Numerical Problems",
            uploadDate: "20 Mar 2024",
            fileType: "PDF",
            fileSize: "1.1 MB",
            downloadUrl: "#",
          ),
          CourseMaterial(
            title: "Zeolite Process & Ion Exchange",
            uploadDate: "22 Mar 2024",
            fileType: "PDF",
            fileSize: "3.5 MB",
            downloadUrl: "#",
          ),
          CourseMaterial(
            title: "Water Treatment Case Study",
            uploadDate: "25 Mar 2024",
            fileType: "XLSX",
            fileSize: "450 KB",
            downloadUrl: "#",
          ),
        ],
      ),
      const CourseModule(
        moduleName: "Module 3: Electrochemistry",
        materials: [
          CourseMaterial(
            title: "Nernst Equation Derivations",
            uploadDate: "02 Apr 2024",
            fileType: "PDF",
            fileSize: "1.8 MB",
            downloadUrl: "#",
          ),
        ],
      ),
    ];
  }
}
