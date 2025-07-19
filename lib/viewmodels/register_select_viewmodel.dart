import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class YearGroup {
  final int id;
  final String name;

  YearGroup({required this.id, required this.name});

  factory YearGroup.fromJson(Map<String, dynamic> json) {
    return YearGroup(
      id: json['id'],
      name: json['name'],
    );
  }
}
class RegisterSelectViewModel extends ChangeNotifier {
  List<YearGroup> yearGroups = [];
  bool isLoading = false;
  String? error;

  int? selectedYearGroupId;
  String? selectedPeriod;
   Future<void> fetchYearGroups(String token) async {
    final url = Uri.parse('${AuthService.baseUrl}/adminapi/getclassyeargroups');  // Use getter here
    final response = await http.post(
      url,
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
        // Convert JSON list to YearGroup list
        List<dynamic> list = json['classYearGroupList'];
        yearGroups = list.map((item) => YearGroup.fromJson(item)).toList();
        error = null;
      } else {
        error = "No year groups found";
        yearGroups = [];
      }
    } else {
      error = "Failed to fetch year groups";
      yearGroups = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
