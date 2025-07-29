import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/network_service.dart'; // ✅ Don't forget this import!

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  UserModel? user;

  Future<bool> login(String email, String password, String orgId) async {
    isLoading = true; // ✅ Set loading true here first
    errorMessage = null;
    notifyListeners();

    // ✅ Internet check
    if (!await NetworkService().isConnected()) {
      errorMessage = "No Internet Connection. Please try again.";
      isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      final result = await _authService.login(
        email: email,
        password: password,
        organizationId: orgId,
      );

      if (result != null && result.accessToken.isNotEmpty) {
        user = result;
        isLoading = false;
        notifyListeners();
        return true;
      } else {
        errorMessage = "Invalid credentials or server error.";
      }
    } catch (e) {
      errorMessage = "Login failed: $e";
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
