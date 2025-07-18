import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'https://adminapiuat.massivedanamik.com';

  Future<UserModel?> login({
    required String email,
    required String password,
    required String organizationId,
  }) async {
    print('login() called');
    final response = await http.post(
      Uri.parse('$_baseUrl/api/GetUserLoginDetails'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "organizationId": organizationId,
      }),
    );

    print('Request: POST $_baseUrl/api/GetUserLoginDetails');
    print('Request Body: ${jsonEncode({
          "email": email,
          "password": password,
          "organizationId": organizationId,
        })}');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UserModel.fromJson(json);
    }
    return null;
  }

  Future<List<dynamic>?> fetchYearGroups({required String token}) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/GetClassYearGroupList'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "SearchTerm": "",
        "startIndex": "0",
        "endIndex": "5",
      }),
    );

    print('YearGroups Status: ${response.statusCode}');
    print('YearGroups Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json is Map && json.containsKey('classYearGroupList')) {
        return json['classYearGroupList'] as List<dynamic>;
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
  final response = await http.post(
    Uri.parse('$_baseUrl/api/GenerateResetPasswordCode'),
    headers: {
      'Content-Type': 'application/json', // Required Header ✅
    },
    body: jsonEncode({
      "OrganizationId": organizationId,
      "Email": email,
    }),
  );

  print('Generate Reset Password Request: POST $_baseUrl/api/GenerateResetPasswordCode');
  print('Request Body: ${jsonEncode({
    "OrganizationId": organizationId,
    "Email": email,
  })}');
  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as bool;
  } else {
    throw Exception('Failed to generate reset password code');
  }
}
Future<bool> validateResetPasswordCode({
  required int organizationId,
  required String code,
}) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/ValidateResetPasswordCode'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "OrganizationId": organizationId,
      "Code": code,
    }),
  );

  print('Validate OTP Request: POST $_baseUrl/api/ValidateResetPasswordCode');
  print('Request Body: ${jsonEncode({"OrganizationId": organizationId, "Code": code})}');
  print('Status Code: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as bool;
  } else {
    throw Exception('Failed to validate reset password code');
  }
}
Future<bool> resetPasswordWithCode({
  required int organizationId,
  required String code,
  required String newPassword,
}) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/api/ResetPasswordWithCode'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "OrganizationId": organizationId,
      "Code": code,
      "NewPassword": newPassword,
    }),
  );

  print('Reset Password Request: POST $_baseUrl/api/ResetPasswordWithCode');
  print('Request Body: ${response.body}');
  print('Status Code: ${response.statusCode}');

  if (response.statusCode == 200) {
    return jsonDecode(response.body) as bool;
  } else {
    throw Exception('Failed to reset password');
  }
}

}
