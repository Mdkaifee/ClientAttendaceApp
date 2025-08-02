import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../services/network_service.dart'; // ✅ NEW
import '../models/calendar_model.dart';
import '../models/year_group_model.dart';

class RegisterSelectViewModel extends ChangeNotifier {
  List<YearGroup> yearGroups = [];
  List<CalendarModel> calendarModels = [];
  bool isLoading = false;
  String? error;

  int? selectedYearGroupId;
  int? selectedPeriodId;

  Future<void> fetchYearGroups(String token) async {
    isLoading = true;
    error = null;
    notifyListeners();

    // ✅ Internet check
    if (!await NetworkService().isConnected()) {
      error = "No Internet Connection. Please try again.";
      isLoading = false;
      notifyListeners();
      return;
    }

    final yearGroupResponse = await AuthService().fetchYearGroups(token);

    if (yearGroupResponse != null) {
      yearGroups = yearGroupResponse.map((item) => YearGroup.fromJson(item)).toList();
      error = null;
    } else {
      error = "Failed to fetch year groups or token expired,Please Login Again."; // Specific error message
      yearGroups = [];
    }

    isLoading = false;
    notifyListeners();
  }



  Future<void> fetchCalendarModels({
    required int educationCentreClassId,
    required String token,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    // ✅ Internet check
    if (!await NetworkService().isConnected()) {
      error = "No Internet Connection. Please try again.";
      isLoading = false;
      notifyListeners();
      return;
    }

    final calendarModelResponse = await AuthService().fetchCalendarModels(
      educationCentreClassId: educationCentreClassId,
      token: token,
    );

    if (calendarModelResponse != null) {
      calendarModels = calendarModelResponse.map((item) => CalendarModel.fromJson(item)).toList();
      error = null;
    } else {
      error = "No calendar models found";
      calendarModels = [];
    }

    selectedPeriodId = null;
    isLoading = false;
    notifyListeners();
  }

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
