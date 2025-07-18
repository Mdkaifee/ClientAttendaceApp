import 'package:flutter/material.dart';
import '../models/student_attendance_summary_model.dart';
import '../services/api_service.dart';

class StudentAttendanceSummaryViewModel extends ChangeNotifier {
  final ApiService apiService = ApiService();

  bool isLoading = false;
  String? error;
  StudentAttendanceSummaryModel? summary;

  Future<void> fetchSummary(String token,int studentId, String attendanceTakenDate) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final json = await apiService.fetchStudentAttendanceSummary(
        token: token,
        studentId: studentId,
        attendanceTakenDate: attendanceTakenDate,
      );
      if (json != null && json['studentAttendanceDetailsInfoDetail'] != null) {
        summary = StudentAttendanceSummaryModel.fromJson(json['studentAttendanceDetailsInfoDetail']);
      } else {
        error = "No data found";
      }
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }
}
