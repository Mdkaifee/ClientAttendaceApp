import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/calendar_model.dart';  // Import your CalendarModel here

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
  List<CalendarModel> calendarModels = [];
  bool isLoading = false;
  String? error;

  int? selectedYearGroupId;
  int? selectedPeriodId;

  Future<void> fetchYearGroups(String token) async {
    isLoading = true;
    notifyListeners();

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
        "endIndex": "5",
      }),
    );

    print('YearGroups Status: ${response.statusCode}');
    print('YearGroups Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json is Map && json.containsKey('classYearGroupList')) {
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
  }Future<void> fetchCalendarModels({
  required int educationCentreClassId,  // Only this param needed now
  required String token,
}) async {
  isLoading = true;
  notifyListeners();

  final payload = {
    "EducationCentreClassId": educationCentreClassId.toString(),  // Convert to string if needed
  };

  print('CalendarModels Request Payload: ${jsonEncode(payload)}');

  final url = Uri.parse('https://attendanceapiuat.massivedanamik.com/api/GetCalendarModels');
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
      List<dynamic> list = json['calendarModelsList'];
      calendarModels = list.map((item) => CalendarModel.fromJson(item)).toList();
      error = null;
    } else {
      error = "No calendar models found";
      calendarModels = [];
    }
  } else {
    error = "Failed to fetch calendar models";
    calendarModels = [];
  }

  selectedPeriodId = null;

  isLoading = false;
  notifyListeners();
}


  // Add these methods:
  void setSelectedYearGroup(int? id, String token) {
  selectedYearGroupId = id;

  if (id != null) {
    fetchCalendarModels(
      educationCentreClassId: id,
      token: token,
    );
  } else {
    calendarModels = [];
    selectedPeriodId = null;
    notifyListeners();
  }
}


  void setSelectedPeriod(int? id) {
    selectedPeriodId = id;
    notifyListeners();
  }
}
