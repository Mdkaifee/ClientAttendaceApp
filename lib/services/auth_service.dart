import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'network_service.dart';

class AuthService {
  static const String baseUrl = 'https://adminapiuat.massivedanamik.com';

  Future<UserModel?> login({
    required String email,
    required String password,
    required String organizationId,
  }) async {
    print('login() called');
    if (!await NetworkService().isConnected()) {
      print('❌ No Internet Connection');
      return null;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/GetUserLoginDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "organizationId": organizationId,
      }),
    );

    print('Request: POST $baseUrl/api/GetUserLoginDetails');
    print(
      'Request Body: ${jsonEncode({"email": email, "password": password, "organizationId": organizationId})}',
    );
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    }
    return null;
  }

  Future<List<dynamic>?> fetchYearGroups(String token) async {
    final url = Uri.parse('${AuthService.baseUrl}/adminapi/getclassyeargroups');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "SearchTerm": "",
        "startIndex": "0",
        "endIndex": "100",
      }),
    );

    print('YearGroups Status: ${response.statusCode}');
    print('YearGroups Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json is Map && json.containsKey('classYearGroupList')) {
        return json['classYearGroupList'] as List<dynamic>;
      }
    } else if (response.statusCode == 401) {
      // Token expired, return null
      return null;
    }
    return null;
  }

  Future<List<dynamic>?> fetchCalendarModels({
    required int educationCentreClassId,
    required String token,
  }) async {
    final payload = {
      "EducationCentreClassId": educationCentreClassId.toString(),
    };

    final url = Uri.parse(
      'https://attendanceapiuat.massivedanamik.com/api/GetCalendarModels',
    );
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    print('CalendarModels Status: ${response.statusCode}');
    print('CalendarModels Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['result'] == true && json['calendarModelsList'] != null) {
        return json['calendarModelsList'] as List<dynamic>;
      }
    }
    return null;
  }

  /// Forgot password method added here ✅
  /// ✅ Corrected method with required headers
  Future<bool> generateResetPasswordCode({
    required int organizationId,
    required String email,
  }) async {
    if (!await NetworkService().isConnected()) {
      print('❌ No Internet Connection');
      return false;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/GenerateResetPasswordCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"OrganizationId": organizationId, "Email": email}),
    );

    print(
      'Generate Reset Password Request: POST $baseUrl/api/GenerateResetPasswordCode',
    );
    print(
      'Request Body: ${jsonEncode({"OrganizationId": organizationId, "Email": email})}',
    );
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      // Return the value of the 'result' field as bool
      return jsonResponse['result'] == true;
    } else {
      throw Exception(
        'Failed to generate reset password code, status code: ${response.statusCode}, response: ${response}, body: ${response.body}, organizationId: $organizationId, email: $email, headers: ${response.headers}, url: ${Uri.parse('$baseUrl/api/GenerateResetPasswordCode')}',
      );
    }
  }

  Future<bool> validateResetPasswordCode({
    required int organizationId,
    required String code,
    required String email,
  }) async {
    if (!await NetworkService().isConnected()) {
      print('❌ No Internet Connection');
      return false;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/ValidateResetPasswordCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "OrganizationId": organizationId,
        "Code": code,
        "Email": email,
      }),
    );

    print('Validate OTP Request: POST $baseUrl/api/ValidateResetPasswordCode');
    print(
      'Request Body: ${jsonEncode({"OrganizationId": organizationId, "Code": code, "Email": email})}',
    );
    print('Request Headers: ${response.headers}');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['result'] == true;
    } else {
      throw Exception('Failed to validate reset password code');
    }
  }

  Future<bool> resetPasswordWithCode({
    required int organizationId,
    required String code,
    required String newPassword,
  }) async {
    if (!await NetworkService().isConnected()) {
      print('❌ No Internet Connection');
      return false;
    }
    final response = await http.post(
      Uri.parse('$baseUrl/api/ResetPasswordWithCode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "OrganizationId": organizationId,
        "Code": code,
        "NewPassword": newPassword,
      }),
    );

    print('Reset Password Request: POST $baseUrl/api/ResetPasswordWithCode');
    print('Request Body: ${response.body}');
    print(
      'OrganizationId: $organizationId, Code: $code, NewPassword: $newPassword',
    );
    print('Request Headers: ${response.headers}');
    print('Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['result'] == true;
    } else {
      throw Exception('Failed to reset password');
    }
  }
}
