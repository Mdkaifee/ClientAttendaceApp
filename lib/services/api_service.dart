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
    final url = Uri.parse('$_attendanceBaseUrl/api/StudentAttendanceDataGet');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      "ClassId": classId,
      "AttendanceTakenDate": attendanceTakenDate,
      "CalendarModelId": calendarModelId,
      "SortBy": sortBy,
    });

    // Log the request details
    print('--- fetchAttendance Request ---');
    print('POST $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    // Log the response details
    print('--- fetchAttendance Response ---');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json is Map && json.containsKey('studentsAttendanceList')) {
        return json['studentsAttendanceList'] as List<dynamic>;
      }
      if (json is List) {
        return json;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchStudentAttendanceSummary({
    required String token,
    required int studentId,
    required String attendanceTakenDate,
  }) async {
    final url = Uri.parse('$_attendanceBaseUrl/api/StudentAttendanceDetailsInfo');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      "StudentId": studentId,
      "AttendanceTakenDate": attendanceTakenDate,
    });

    // Log the request details
    print('--- fetchStudentAttendanceSummary Request ---');
    print('POST $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(url, headers: headers, body: body);

    // Log the response details
    print('--- fetchStudentAttendanceSummary Response ---');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json;
    }
    return null;
  }
}
