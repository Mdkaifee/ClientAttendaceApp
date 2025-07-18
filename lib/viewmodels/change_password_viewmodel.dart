import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  bool success = false;

  Future<void> resetPassword({
    required int organizationId,
    required String code,
    required String newPassword,
  }) async {
    isLoading = true;
    errorMessage = null;
    success = false;
    notifyListeners();

    try {
      // Call your AuthService API method to reset password
      success = await _authService.resetPasswordWithCode(
        organizationId: organizationId,
        code: code,
        newPassword: newPassword,
      );
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
