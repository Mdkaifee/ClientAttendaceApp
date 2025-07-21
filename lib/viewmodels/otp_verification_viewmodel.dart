import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OtpVerificationViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;     // For verifying OTP
  bool isResending = false;   // For resending OTP
  bool success = false;
  String? errorMessage;
  String? resendMessage;

// For direct navigation to ChangePasswordScreen
 // Future<void> validateOtp(int organizationId, String code) async {
  //   isLoading = true;
  //   errorMessage = null;
  //   notifyListeners();

  //   try {
  //     success = await _authService.validateResetPasswordCode(
  //       organizationId: organizationId,
  //       code: code,
  //     );
  //     if (!success) errorMessage = 'Invalid OTP code';
  //   } catch (e) {
  //     errorMessage = e.toString();
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> validateOtp(int organizationId, String code) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      success = await _authService.validateResetPasswordCode(
        organizationId: organizationId,
        code: code,
      );
      if (!success) errorMessage = 'Invalid OTP code';
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resendCode(int organizationId, String email) async {
    isResending = true;
    resendMessage = null;
    notifyListeners();

    try {
      bool resendSuccess = await _authService.generateResetPasswordCode(
        organizationId: organizationId,
        email: email,
      );
      if (resendSuccess) {
        resendMessage = 'Resend OTP sent, please check your email.';
      } else {
        resendMessage = 'Failed to resend OTP. Please try again.';
      }
    } catch (e) {
      resendMessage = 'Error: ${e.toString()}';
    } finally {
      isResending = false;
      notifyListeners();
    }
  }
}
