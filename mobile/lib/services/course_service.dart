import 'dart:convert';
import 'package:flutter/services.dart';

class CourseService {
  static CourseService? _instance;
  Map<String, dynamic>? _courseData;

  CourseService._();

  static CourseService get instance {
    _instance ??= CourseService._();
    return _instance!;
  }

  Future<void> loadCourses() async {
    if (_courseData != null) return;
    
    final jsonString = await rootBundle.loadString('courses.json');
    _courseData = jsonDecode(jsonString) as Map<String, dynamic>;
  }

  List<String> getCoursesForStudent({
    required int year,
    required int semester,
    String? specialization,
  }) {
    if (_courseData == null) return [];
    
    final courses = <String>[];
    
    final coreCurriculum = _courseData!['core_curriculum'] as List;
    for (final entry in coreCurriculum) {
      final entryYear = entry['year'] as int;
      final entrySemester = entry['semester'] as int;
      
      if (entryYear == year && entrySemester == semester) {
        final modules = entry['modules'] as List;
        courses.addAll(modules.map((m) => m.toString()));
      }
    }
    
    if (specialization != null && specialization.isNotEmpty) {
      final specializations = _courseData!['specializations'] as List;
      for (final spec in specializations) {
        if (spec['track'] == specialization) {
          final modules = spec['modules'] as List;
          final semesterKey = 'Year $year, S$semester';
          
          for (final module in modules) {
            if (module['semester'] == semesterKey) {
              final specCourses = module['courses'] as List;
              courses.addAll(specCourses.map((c) => c.toString()));
            }
          }
          break;
        }
      }
    }
    
    return courses.toSet().toList();
  }

  List<String> getSpecializations() {
    if (_courseData == null) return [];
    
    final specializations = _courseData!['specializations'] as List;
    return specializations.map((s) => s['track'].toString()).toList();
  }

  bool needsSpecialization(int year, int semester) {
    return (year == 2 && semester >= 3) || year >= 3;
  }
}

