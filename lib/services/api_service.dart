import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/calendar_model.dart';

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

Future<List<CalendarModel>?> fetchCalendarModels({
  required int educationCentreId,
  required int yearGroupId,
  required String token,
}) async {
  final url = Uri.parse('$_attendanceBaseUrl/api/GetCalendarModels');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
  final body = jsonEncode({
    "educationCentreId": educationCentreId,
    "yearGroupId": yearGroupId,
  });

  // Log the request details
  print('--- fetchCalendarModels Request ---');
  print('POST $url');
  print('Headers: $headers');
  print('Body: $body');

  final response = await http.post(url, headers: headers, body: body);

  // Log the response details
  print('--- fetchCalendarModels Response ---');
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    if (json['result'] == true && json['calendarModelsList'] != null) {
      final List list = json['calendarModelsList'];
      return list.map((e) => CalendarModel.fromJson(e)).toList();
    }
  }
  return null;
}

Future<Map<String, dynamic>?> saveStudentAttendance({
  required String token,
  required int classId,
  required String lateInMinutes,
  required String markCodeId,
  String? markSubCodeId,
  required int studentId,
  String? calendarId,
  required int calendarModelId,
  required String studentFirstName,
  required String studentLastName,
  required String educationCentreClassIdDesc,
  
}) async {
  final url = Uri.parse('https://attendanceapiuat.massivedanamik.com/api/StudentAttendanceDataSave');

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final body = jsonEncode({
    "ClassId": classId,
    "LateInMinutes": lateInMinutes,
    "MarkCodeId": markCodeId,
    "MarkSubCodeId": markSubCodeId,
    "StudentId": studentId,
    "CalendarId": calendarId,
    "CalendarModelId": calendarModelId,
    "StudentFirstName": studentFirstName,
    "StudentLastName": studentLastName,
    "EducationCentreClassIdDesc": educationCentreClassIdDesc,
  });

  print('--- saveStudentAttendance Request ---');
  print('POST $url');
  print('Headers: $headers');
  print('Body: $body');

  final response = await http.post(url, headers: headers, body: body);

  print('--- saveStudentAttendance Response ---');
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return json;
  }

  return null;
}

}