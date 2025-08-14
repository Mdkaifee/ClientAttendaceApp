import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart'; // Import the pinput package
import 'package:provider/provider.dart';
import '../viewmodels/otp_verification_viewmodel.dart';
import 'change_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final int organizationId;
  final String email;

  OtpVerificationScreen({required this.organizationId, required this.email});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late TextEditingController otpController;
  late Timer timer;
  int remainingSeconds = 120;
  bool resendAvailable = false;

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
    startTimer();
    startListeningForOtp();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
        } else {
          resendAvailable = true;
          timer.cancel();
        }
      });
    });
  }

  // Start listening for OTP auto-fill (only for Android and iOS)
  void startListeningForOtp() {
    // Optionally, you can use SMS Retriever API to auto-fill OTP. This step requires platform-specific code.
    // For simplicity, we're assuming the user manually enters the OTP for now.
  }

  String get otpCode => otpController.text;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpVerificationViewModel(),
      child: Consumer<OtpVerificationViewModel>(
        builder: (context, vm, _) {
          bool isOtpComplete = otpCode.length == 6;

          return Scaffold(
            backgroundColor: Color(0xFF162244),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset("assets/logo.png", width: 80),
                          SizedBox(height: 16),
                          Text(
                            'Verification code',
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Enter the 6 digit code we sent to your\nregistered email address before the\ncode expires.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Step Indicators with connecting lines
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StepIndicator(
                          label: 'Submit email address',
                          isActive: false,
                          isLast: false,
                        ),
                        StepIndicator(
                          label: 'Enter verification code',
                          isActive: true,
                          isLast: false,
                        ),
                        StepIndicator(
                          label: 'Change password',
                          isActive: false,
                          isLast: false,
                        ),
                        StepIndicator(
                          label: 'Login again',
                          isActive: false,
                          isLast: true,
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // OTP Boxes using Pinput
                    Pinput(
                      controller: otpController,
                      length: 6,
                      onCompleted: (pin) {
                        setState(() {
                          otpController.text = pin; // Handle the completed OTP
                        });
                      },
                      onChanged: (pin) {
                        setState(() {
                          otpController.text = pin; // Handle OTP change
                        });
                      },
                      defaultPinTheme: PinTheme(
                        width: 40,
                        height: 60,
                        textStyle: TextStyle(fontSize: 24, color: Colors.white),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white70),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Timer
                    Text(
                      "${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(color: Colors.white70),
                    ),

                    SizedBox(height: 24),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: (vm.isLoading || !isOtpComplete)
                            ? null
                            : () async {
                                await vm.validateOtp(
                                  widget.organizationId,
                                  otpCode,
                                  widget.email,
                                );
                                if (vm.success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChangePasswordScreen(
                                        organizationId: widget.organizationId,
                                        code: otpCode,
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: vm.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Verify', style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Error Message for verification
                    if (vm.errorMessage != null)
                      Text(
                        vm.errorMessage!,
                        style: TextStyle(color: Colors.redAccent),
                      ),

                    SizedBox(height: 20),

                    // Resend OTP message
                    if (vm.resendMessage != null)
                      Text(
                        vm.resendMessage!,
                        style: TextStyle(color: Colors.greenAccent),
                      ),

                    SizedBox(height: 8),

                    // Resend code button
                    TextButton.icon(
                      onPressed: (resendAvailable && !vm.isResending)
                          ? () async {
                              setState(() {
                                resendAvailable = false;
                                remainingSeconds = 120;
                                startTimer();
                              });
                              await vm.resendCode(
                                // widget.organizationId,
                                email: widget.email,
                              );
                            }
                          : null,
                      icon: Icon(
                        Icons.refresh,
                        color: (resendAvailable && !vm.isResending)
                            ? Colors.blueAccent
                            : Colors.grey,
                      ),
                      label: vm.isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.blueAccent,
                              ),
                            )
                          : Text(
                              'Resend code',
                              style: TextStyle(
                                color: (resendAvailable && !vm.isResending)
                                    ? Colors.blueAccent
                                    : Colors.grey,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No longer checking clipboard, handling OTP via Pinput widget
  }
}

class StepIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLast;

  StepIndicator({
    required this.label,
    this.isActive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Circle + vertical line column
        Column(
          children: [
            Icon(
              Icons.radio_button_checked,
              color: isActive ? Colors.white : Colors.white38,
              size: 18,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: Colors.white38,
                margin: EdgeInsets.only(top: 1),
              ),
          ],
        ),
        SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
