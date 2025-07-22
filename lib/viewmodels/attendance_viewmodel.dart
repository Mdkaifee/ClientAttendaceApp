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

//   Future<bool> submitAttendance({
//   required String token,
//   required int classId,
//   required int calendarModelId,
//   required String educationCentreClassIdDesc,
// }) async {
//   bool allSuccess = true;

//   for (var student in filteredStudents) {
//     // Replace defaults or add validation as needed
//     final lateMinutes = student.lateMinutes.isNotEmpty ? student.lateMinutes : "0";
//     final markCodeId = student.markCodeId ?? "1040";   // replace with default or actual selected
//     final markSubCodeId = student.markSubCodeId;       // nullable

//     final response = await ApiService().saveStudentAttendance(
//       token: token,
//       classId: classId,
//       lateInMinutes: lateMinutes,
//       markCodeId: markCodeId,
//       markSubCodeId: markSubCodeId,
//       studentId: student.studentId,
//       calendarId: null,
//       calendarModelId: calendarModelId,
//       studentFirstName: student.studentName.split(' ').first,
//       studentLastName: student.studentName.split(' ').length > 1 ? student.studentName.split(' ').last : '',
//       educationCentreClassIdDesc: educationCentreClassIdDesc,
//     );

//     if (response == null || response['result'] != true) {
//       allSuccess = false;
//     }
//   }

//   return allSuccess;
// }
Future<bool> markStudent({
  required String token,
  required int classId,
  required int calendarModelId,
  required String educationCentreClassIdDesc,
  required AttendanceModel student,
  required String markCodeId,
  String? markSubCodeId,
}) async {
  final lateMinutes = student.lateMinutes.isNotEmpty ? student.lateMinutes : "0";

  final response = await _apiService.saveStudentAttendance(
    token: token,
    classId: classId,
    lateInMinutes: lateMinutes,
    markCodeId: markCodeId,
    markSubCodeId: markSubCodeId,
    studentId: student.studentId,
    calendarId: null,
    calendarModelId: calendarModelId,
    studentFirstName: student.studentName.split(' ').first,
    studentLastName: student.studentName.split(' ').length > 1 ? student.studentName.split(' ').last : '',
    educationCentreClassIdDesc: educationCentreClassIdDesc,
  );
  return (response != null && response['result'] == true);
}


}
