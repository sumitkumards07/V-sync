import 'package:flutter/foundation.dart';

@immutable
class CourseMaterial {
  final String title;
  final String uploadDate;
  final String fileType; // PDF, PPT, XLSX, DOCX, etc.
  final String fileSize;
  final String downloadUrl;

  const CourseMaterial({
    required this.title,
    required this.uploadDate,
    required this.fileType,
    required this.fileSize,
    required this.downloadUrl,
  });

  factory CourseMaterial.fromJson(Map<String, dynamic> json) => CourseMaterial(
        title: json['title'] as String,
        uploadDate: json['uploadDate'] as String,
        fileType: json['fileType'] as String,
        fileSize: json['fileSize'] as String,
        downloadUrl: json['downloadUrl'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'uploadDate': uploadDate,
        'fileType': fileType,
        'fileSize': fileSize,
        'downloadUrl': downloadUrl,
      };
}

@immutable
class CourseModule {
  final String moduleName; // e.g., "Module 1: Introduction"
  final List<CourseMaterial> materials;

  const CourseModule({
    required this.moduleName,
    required this.materials,
  });
}
