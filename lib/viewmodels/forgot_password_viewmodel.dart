import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/network_service.dart'; // ✅ Required for checking internet

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  bool success = false;

  Future<void> sendResetCode({
    int organizationId = 1003,
    required String email,
    bool isResend = false,
  }) async {
    isLoading = true;
    errorMessage = null;
    success = false;
    notifyListeners();
    // ✅ Internet Check First
    if (!await NetworkService().isConnected()) {
      errorMessage = "No Internet Connection. Please try again.";
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      success = await _authService.generateResetPasswordCode(
        organizationId: organizationId,
        email: email,
      );

      if (success) {
        print(
          isResend
              ? "Reset code resent successfully."
              : "Reset code sent successfully.",
        );
      } else {
        errorMessage = "Failed to send reset code. Please try again.";
      }
    } catch (e) {
      errorMessage = "An error occurred: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSuccess() {
    success = false;
    notifyListeners();
  }
}
