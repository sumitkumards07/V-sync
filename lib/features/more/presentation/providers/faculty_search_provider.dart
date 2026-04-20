import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vsync/core/utils/entity/faculty_record.dart';
import 'package:flutter/material.dart';

part 'faculty_search_provider.g.dart';

@immutable
class FacultySearchState {
  final List<FacultyRecord> allFaculty;
  final List<FacultyRecord> filteredFaculty;
  final String searchQuery;
  final String? selectedCourseCode;
  final List<String> availableCourses;

  const FacultySearchState({
    required this.allFaculty,
    required this.filteredFaculty,
    this.searchQuery = '',
    this.selectedCourseCode,
    required this.availableCourses,
  });

  FacultySearchState copyWith({
    List<FacultyRecord>? filteredFaculty,
    String? searchQuery,
    String? selectedCourseCode,
  }) {
    return FacultySearchState(
      allFaculty: allFaculty,
      filteredFaculty: filteredFaculty ?? this.filteredFaculty,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCourseCode: selectedCourseCode ?? this.selectedCourseCode,
      availableCourses: availableCourses,
    );
  }
}

@riverpod
class FacultySearch extends _$FacultySearch {
  @override
  FacultySearchState build() {
    // Mock Data for demonstration as requested
    final mockFaculty = _getMockFaculty();
    final courses = mockFaculty.map((e) => e.courseCode).toSet().toList()..sort();
    
    return FacultySearchState(
      allFaculty: mockFaculty,
      filteredFaculty: mockFaculty,
      availableCourses: courses,
      selectedCourseCode: courses.firstOrNull,
    );
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _filter();
  }

  void selectCourse(String courseCode) {
    state = state.copyWith(selectedCourseCode: courseCode);
    _filter();
  }

  void _filter() {
    var filtered = state.allFaculty;
    
    if (state.selectedCourseCode != null) {
      filtered = filtered.where((f) => f.courseCode == state.selectedCourseCode).toList();
    }
    
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      filtered = filtered.where((f) => 
        f.facultyName.toLowerCase().contains(q) || 
        f.courseCode.toLowerCase().contains(q)
      ).toList();
    }
    
    state = state.copyWith(filteredFaculty: filtered);
  }

  List<FacultyRecord> _getMockFaculty() {
    return [
      const FacultyRecord(
        facultyName: "DASARI BOSU BABU",
        courseCode: "CHY1009",
        courseName: "Chemistry and Environmental Studies",
        slot: "B1+TB1",
        initials: "DB",
        colorHex: 0xFF6366F1,
      ),
      const FacultyRecord(
        facultyName: "SACHIL KUMAR",
        courseCode: "CHY1009",
        courseName: "Chemistry and Environmental Studies",
        slot: "A2+TA2",
        initials: "SK",
        colorHex: 0xFFEC4899,
      ),
      const FacultyRecord(
        facultyName: "PRIYA SHARMA",
        courseCode: "MAT1011",
        courseName: "Calculus for Engineers",
        slot: "C1+TC1",
        initials: "PS",
        colorHex: 0xFF10B981,
      ),
      const FacultyRecord(
        facultyName: "ANANYA REDDY",
        courseCode: "CSE1001",
        courseName: "Problem Solving and Computer Programming",
        slot: "L1+L2",
        initials: "AR",
        colorHex: 0xFFF59E0B,
      ),
      const FacultyRecord(
        facultyName: "VIKRAM SINGH",
        courseCode: "PHY1001",
        courseName: "Engineering Physics",
        slot: "D2+TD2",
        initials: "VS",
        colorHex: 0xFF3B82F6,
      ),
      const FacultyRecord(
        facultyName: "MEENAKSHI IYER",
        courseCode: "CSE1002",
        courseName: "Object Oriented Programming",
        slot: "E1+TE1",
        initials: "MI",
        colorHex: 0xFF8B5CF6,
      ),
    ];
  }
}
