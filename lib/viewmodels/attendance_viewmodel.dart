import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/attendance_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  // --- Add sort logic ---
  String selectedSortOption = "default";

  void sortStudents() {
    if (selectedSortOption == "mark code asc") {
      students.sort((a, b) => (a.markCodeId ?? "").compareTo(b.markCodeId ?? ""));
    } else if (selectedSortOption == "mark code desc") {
      students.sort((a, b) => (b.markCodeId ?? "").compareTo(a.markCodeId ?? ""));
    }
    notifyListeners();
  }
  // -----------------------

  List<AttendanceModel> get filteredStudents {
    if (_searchQuery.trim().isEmpty) return students;
    final query = _searchQuery.toLowerCase();
    return students.where((student) =>
      student.studentName.toLowerCase().contains(query)
    ).toList();
  }
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
          markCodeId: item['markCodeId']?.toString() ?? "",
          markSubCodeId: item['markSubCodeId']?.toString() ?? "",
          lateMinutes: item['lateMinutes']?.toString() ?? "",
          token: token,
          classId: classId,
          calendarModelId: calendarModelId,
          educationCentreClassIdDesc: item['educationCentreClassIdDesc'] ?? 'Dynamics 11 Plus Tuition Centre',  // Default value if empty
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
Future<bool> markStudent(
  AttendanceModel student,
  String? markSubCodeId,
) async {
  String lateMinutes = student.lateMinutes.isNotEmpty ? student.lateMinutes : "0";

  if (student.markCodeId == "1041") {
    final int? lateMinutesInt = int.tryParse(lateMinutes);
    if (lateMinutesInt == null || lateMinutesInt <= 0) {
      return false; // Late minutes validation failed
    }
  }

  if (student.markCodeId == "1040" || student.markCodeId == "1041") {
    markSubCodeId = null;
  }

  if (student.markCodeId == "1042" && markSubCodeId == null) {
    return false; // Absent requires sub-mark
  }

  // Debugging: Log the request body before sending it
  print("Sending API request to save student attendance:");
  print("Token: ${student.token}");
  print("Class ID: ${student.classId}");
  print("Late Minutes: $lateMinutes");
  print("Mark Code ID: ${student.markCodeId}");
  print("Mark Sub Code ID: $markSubCodeId");
  print("Student ID: ${student.studentId}");
  print("Calendar Model ID: ${student.calendarModelId}");
  print("Student Name: ${student.studentName}");
  print("Education Centre Class ID Desc: ${student.educationCentreClassIdDesc}");

  final response = await _apiService.saveStudentAttendance(
    token: student.token,
    classId: student.classId,
    lateInMinutes: lateMinutes,
    markCodeId: student.markCodeId ?? "", // Ensure markCodeId is not null
    markSubCodeId: markSubCodeId,
    studentId: student.studentId,
    calendarModelId: student.calendarModelId,
    studentFirstName: student.studentName.split(' ').first,
    studentLastName: student.studentName.split(' ').length > 1
        ? student.studentName.split(' ').last
        : '',
    educationCentreClassIdDesc: student.educationCentreClassIdDesc, // Ensure it's passed correctly
  );

  // Check the response
  print("API response: $response");

  // If the status is 200, show a toast message
  if (response != null && response['result'] == true) {
    Fluttertoast.showToast(
      msg: "Attendance for ${student.studentName} has been marked.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
    );
    return true;
  } else {
    // If API fails, you can show a failure message
    Fluttertoast.showToast(
      msg: "Failed to mark attendance for ${student.studentName}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
    );
    return false;
  }
}

  //Submit attendance register
  Future<bool> submitAttendanceRegister({
  required String token,
  required int calendarModelId,
  required int educationCentreClassId,
}) async {
  final result = await _apiService.submitAttendanceRegister(
    token: token,
    calendarModelId: calendarModelId,
    educationCentreClassId: educationCentreClassId,
  );
  return result != null && result['result'] == true;
}

}
