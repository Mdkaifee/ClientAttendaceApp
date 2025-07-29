import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/attendance_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/network_service.dart';

class AttendanceViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool isLoading = false;
  List<AttendanceModel> students = [];
  String? error;

  // Store the fetched mark codes and sub-mark codes
  List<dynamic> markCodes = [];
  List<dynamic> markSubCodes = [];

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
            educationCentreClassIdDesc: item['educationCentreClassIdDesc'] ?? 'Dynamics 11 Plus Tuition Centre',
          )
        ).toList();
      } else {
        error = "Attendance not found";
      }
    } catch (e) {
      error = "Error: $e";
    }

    // Fetch the mark codes and sub-mark codes
    await loadMarkCodes(token);

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMarkCodes(String token) async {
    // Load mark codes
    final markCodeData = await _apiService.fetchMarkCodes(token: token);
    if (markCodeData != null) {
      markCodes = markCodeData;
    }

    // Load sub-mark codes
    final markSubCodeData = await _apiService.fetchMarkSubCodes(token: token);
    if (markSubCodeData != null) {
      markSubCodes = markSubCodeData;
    }

    notifyListeners();
  }
  Future<bool> markStudent(AttendanceModel student, String? markSubCodeId) async {
  // Check internet connection before proceeding
  if (!await NetworkService().isConnected()) {
    Fluttertoast.showToast(msg: "No Internet Connection");
    return false;
  }

  String lateMinutes = student.lateMinutes.isNotEmpty ? student.lateMinutes : "0";

  if (student.markCodeId == "1041") {
    final int? lateMinutesInt = int.tryParse(lateMinutes);
    if (lateMinutesInt == null || lateMinutesInt <= 0) {
      return false;
    }
  }

  if (student.markCodeId == "1040" || student.markCodeId == "1041") {
    markSubCodeId = null;
  }

  if (student.markCodeId == "1042" && markSubCodeId == null) {
    return false;
  }

  final response = await _apiService.saveStudentAttendance(
    token: student.token,
    classId: student.classId,
    lateInMinutes: lateMinutes,
    markCodeId: student.markCodeId ?? "",
    markSubCodeId: student.markCodeId == "1042" ? markSubCodeId : null,
    studentId: student.studentId,
    calendarModelId: student.calendarModelId,
    studentFirstName: student.studentName.split(' ').first,
    studentLastName: student.studentName.split(' ').length > 1
        ? student.studentName.split(' ').last
        : '',
    educationCentreClassIdDesc: student.educationCentreClassIdDesc,
  );

  return response != null && response['result'] == true;
}



  // Submit attendance register
 Future<bool> submitAttendanceRegister({
  required String token,
  required int calendarModelId,
  required int educationCentreClassId,
}) async {
  if (!await NetworkService().isConnected()) {
    Fluttertoast.showToast(msg: "No Internet Connection");
    return false;
  }

  final result = await _apiService.submitAttendanceRegister(
    token: token,
    calendarModelId: calendarModelId,
    educationCentreClassId: educationCentreClassId,
  );
  return result != null && result['result'] == true;
}
}