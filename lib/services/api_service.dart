import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _attendanceBaseUrl = 'https://attendanceapiuat.massivedanamik.com';

  Future<List<dynamic>?> fetchAttendance({
    required String token,
    required int classId,
    required String attendanceTakenDate,
    required int calendarModelId,
    String sortBy = "Default",
  }) async {
    final response = await http.post(
      Uri.parse('$_attendanceBaseUrl/api/StudentAttendanceDataGet'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "ClassId": classId,
        "AttendanceTakenDate": attendanceTakenDate,
        "CalendarModelId": calendarModelId,
        "SortBy": sortBy,
      }),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json is Map && json.containsKey('studentsAttendanceList')) {
        return json['studentsAttendanceList'] as List<dynamic>;
      }
      // fallback for other structures
      if (json is List) {
        return json;
      }
    }
    return null;
  }
  // Add the method to fetch student attendance summary
Future<Map<String, dynamic>?> fetchStudentAttendanceSummary({
  required String token,
  required int studentId,
  required String attendanceTakenDate,
}) async {
  final response = await http.post(
  Uri.parse('$_attendanceBaseUrl/api/StudentAttendanceDetailsInfo'),
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token', // <-- Make sure you pass the token!
  },
  body: jsonEncode({
    "StudentId": studentId,
    "AttendanceTakenDate": attendanceTakenDate,
  }),
);


  print('Student Attendance Detail Status: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json;
  }
  return null;
}

}
