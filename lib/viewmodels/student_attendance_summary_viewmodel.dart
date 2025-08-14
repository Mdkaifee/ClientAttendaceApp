import 'package:flutter/material.dart';
import '../models/student_attendance_summary_model.dart';
import '../services/api_service.dart';

class StudentAttendanceSummaryViewModel extends ChangeNotifier {
  final ApiService apiService = ApiService();

  bool isLoading = false;
  String? error;
  StudentAttendanceSummaryModel? summary;

  List<dynamic> _calendarMonthAttendanceDetail = [];
  List<dynamic> _student1MonthSummary = [];
  List<dynamic> _student3MonthSummary = [];

  List<dynamic> get calendarMonthAttendanceDetail =>
      _calendarMonthAttendanceDetail;

  List<dynamic> get student1MonthSummary => _student1MonthSummary;

  List<dynamic> get student3MonthSummary => _student3MonthSummary;

  Future<void> fetchSummary(
    String token,
    int studentId,
    String attendanceTakenDate,
  ) async {
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
        summary = StudentAttendanceSummaryModel.fromJson(
          json['studentAttendanceDetailsInfoDetail'],
        );
        _calendarMonthAttendanceDetail =
            json['calendarMonthAttendanceDetail'] ?? [];
        _student1MonthSummary = json['student1MonthSummary'] ?? [];
        _student3MonthSummary = json['student3MonthSummary'] ?? [];
      } else {
        error = "Token expired or no data found.";
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
