import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/attendance_model.dart';

class AttendanceViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<AttendanceModel> students = [];
  String? error;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<AttendanceModel> get filteredStudents {
    if (_searchQuery.trim().isEmpty) return students;
    final query = _searchQuery.toLowerCase();
    return students.where((student) =>
      student.studentName.toLowerCase().contains(query)
    ).toList();
  }

  // Your loadAttendance remains unchanged
  Future<void> loadAttendance({
    required String token,
    required int classId,
    required String attendanceTakenDate,
    required int calendarModelId,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchAttendance(
        token: token,
        classId: classId,
        attendanceTakenDate: attendanceTakenDate,
        calendarModelId: calendarModelId,
      );

      if (data != null) {
        students = data.map<AttendanceModel>((item) =>
            AttendanceModel(
              studentName: '${item['firstName'] ?? ''} ${item['lastName'] ?? ''}'.trim(),
              avatarUrl: item['photothumbnailURL'] ?? '',
              studentId: item['studentId'],
            )
        ).toList();
      } else {
        error = "Attendance not found";
      }
    } catch (e) {
      error = "Error: $e";
    }
    isLoading = false;
    notifyListeners();
  }
}
