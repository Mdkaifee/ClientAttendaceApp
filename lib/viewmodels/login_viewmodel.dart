import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  UserModel? user;

  Future<bool> login(String email, String password, String orgId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

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
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      errorMessage = "Login failed: $e";
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
