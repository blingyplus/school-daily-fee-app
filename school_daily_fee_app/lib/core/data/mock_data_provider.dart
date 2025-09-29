import 'dart:convert';
import 'package:flutter/services.dart';

import '../constants/environment.dart' as env;

class MockDataProvider {
  static final MockDataProvider _instance = MockDataProvider._internal();
  factory MockDataProvider() => _instance;
  MockDataProvider._internal();

  // Cache for loaded JSON data
  final Map<String, dynamic> _cache = {};

  /// Load mock data from assets
  Future<Map<String, dynamic>> loadMockData(String fileName) async {
    if (_cache.containsKey(fileName)) {
      return _cache[fileName]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        '${env.Environment.mockDataPath}$fileName.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);
      _cache[fileName] = data;
      return data;
    } catch (e) {
      print('Error loading mock data for $fileName: $e');
      return {};
    }
  }

  /// Get mock data for authentication
  Future<Map<String, dynamic>> getAuthMockData() async {
    return await loadMockData('auth');
  }

  /// Get mock data for schools
  Future<Map<String, dynamic>> getSchoolsMockData() async {
    return await loadMockData('schools');
  }

  /// Get mock data for students
  Future<Map<String, dynamic>> getStudentsMockData() async {
    return await loadMockData('students');
  }

  /// Get mock data for teachers
  Future<Map<String, dynamic>> getTeachersMockData() async {
    return await loadMockData('teachers');
  }

  /// Get mock data for attendance
  Future<Map<String, dynamic>> getAttendanceMockData() async {
    return await loadMockData('attendance');
  }

  /// Get mock data for fee collections
  Future<Map<String, dynamic>> getFeeCollectionsMockData() async {
    return await loadMockData('fee_collections');
  }

  /// Get mock data for reports
  Future<Map<String, dynamic>> getReportsMockData() async {
    return await loadMockData('reports');
  }

  /// Get mock data for holidays
  Future<Map<String, dynamic>> getHolidaysMockData() async {
    return await loadMockData('holidays');
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
  }

  /// Check if mock data is enabled
  bool get isMockDataEnabled => env.Environment.useMockData;
}
