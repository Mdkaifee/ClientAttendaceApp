import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/network_service.dart'; // ✅ For connection check

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

    // ✅ Internet check
    if (!await NetworkService().isConnected()) {
      errorMessage = "No Internet Connection. Please try again.";
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      success = await _authService.resetPasswordWithCode(
        organizationId: organizationId,
        code: code,
        newPassword: newPassword,
      );

      if (!success) {
        errorMessage = "Failed to reset password. Please try again.";
      }
    } catch (e) {
      errorMessage = "Password reset failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
