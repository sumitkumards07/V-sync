import 'package:flutter/material.dart';

@immutable
class FacultyRecord {
  final String facultyName;
  final String courseCode;
  final String courseName;
  final String slot;
  final String initials;
  final int colorHex;

  const FacultyRecord({
    required this.facultyName,
    required this.courseCode,
    required this.courseName,
    required this.slot,
    required this.initials,
    required this.colorHex,
  });

  factory FacultyRecord.fromJson(Map<String, dynamic> json) => FacultyRecord(
        facultyName: json['facultyName'] as String,
        courseCode: json['courseCode'] as String,
        courseName: json['courseName'] as String,
        slot: json['slot'] as String,
        initials: json['initials'] as String,
        colorHex: json['colorHex'] as int,
      );

  Map<String, dynamic> toJson() => {
        'facultyName': facultyName,
        'courseCode': courseCode,
        'courseName': courseName,
        'slot': slot,
        'initials': initials,
        'colorHex': colorHex,
      };
}
