import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/attendance_model.dart';

class AttendanceViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<AttendanceModel> students = [];
  String? error;

  // Update the method to receive all required parameters:
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
    studentName: '${item['firstName'] ?? ''} ${item['lastName'] ?? ''}',
    avatarUrl: item['photoURL'] ?? '',
              // Add other fields and logic as needed
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
