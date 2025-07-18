import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;
  bool success = false;

  Future<void> sendResetCode(
    int organizationId, 
    String email, {
    bool isResend = false, // 👈 Add optional named parameter here
  }) async {
    isLoading = true;
    errorMessage = null;
    success = false;
    notifyListeners();

    try {
      success = await _authService.generateResetPasswordCode(
        organizationId: organizationId,
        email: email,
      );

      if (success) {
        print(isResend
            ? "Reset code resent successfully."
            : "Reset code sent successfully.");
      } else {
        errorMessage = "Failed to send reset code. Please try again.";
      }
    } catch (e) {
      errorMessage = e.toString();
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
