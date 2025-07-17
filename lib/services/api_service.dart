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
}
