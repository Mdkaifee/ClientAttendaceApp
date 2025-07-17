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

    // LOGGING
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
      Uri.parse('$_baseUrl/api/GetClassYearGroupList'),  // Use _baseUrl here
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
}
