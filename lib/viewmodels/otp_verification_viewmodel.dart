import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/network_service.dart';

class OtpVerificationViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;     // For verifying OTP
  bool isResending = false;   // For resending OTP
  bool success = false;
  String? errorMessage;
  String? resendMessage;

// For direct navigation to ChangePasswordScreen
//  Future<void> validateOtp(int organizationId, String otp,String email) async {
//   isLoading = true;
//   errorMessage = null;
//   success = false;
//   notifyListeners();

//   // TEMPORARY MOCK for UI testing
//   await Future.delayed(Duration(seconds: 1));
//   if (otp == '123456') {
//     success = true;
//   } else {
//     errorMessage = 'Invalid OTP';
//   }

//   isLoading = false;
//   notifyListeners();
// }

/// ✅ Validates the OTP entered by user
  Future<void> validateOtp(int organizationId, String code, String email) async {
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
      success = await _authService.validateResetPasswordCode(
        organizationId: organizationId,
        code: code,
        email: email,
      );

      if (!success) {
        errorMessage = 'Invalid OTP code';
      }
    } catch (e) {
      errorMessage = "Verification failed: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Resends OTP code via email
  Future<void> resendCode(int organizationId, String email) async {
    isResending = true;
    resendMessage = null;
    notifyListeners();

    // ✅ Internet Check First
    if (!await NetworkService().isConnected()) {
      resendMessage = "No Internet Connection. Unable to resend code.";
      isResending = false;
      notifyListeners();
      return;
    }

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
