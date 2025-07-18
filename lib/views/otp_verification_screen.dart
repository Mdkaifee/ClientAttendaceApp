import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  late Timer timer;
  int remainingSeconds = 120;
  bool resendAvailable = false;

  @override
  void initState() {
    super.initState();
    startTimer();
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

  String get otpCode => controllers.map((e) => e.text).join();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OtpVerificationViewModel(),
      child: Consumer<OtpVerificationViewModel>(
        builder: (context, vm, _) {
          bool isOtpComplete = controllers.every((c) => c.text.isNotEmpty);

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
                            style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Enter the 6 digit code we sent to your\nregistered email address before the\ncode expires.",
                            style: TextStyle(color: Colors.white70, fontSize: 18),
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
                        StepIndicator(label: 'Submit email address', isActive: false, isLast: false),
                        StepIndicator(label: 'Enter verification code', isActive: true, isLast: false),
                        StepIndicator(label: 'Change password', isActive: false, isLast: false),
                        StepIndicator(label: 'Login again', isActive: false, isLast: true),
                      ],
                    ),

                    SizedBox(height: 24),

                    // OTP Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          child: Focus(
                            onKey: (FocusNode node, RawKeyEvent event) {
                              if (event is RawKeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.backspace &&
                                  controllers[index].text.isEmpty) {
                                if (index > 0) {
                                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                                  controllers[index - 1].clear();
                                }
                                return KeyEventResult.handled;
                              }
                              return KeyEventResult.ignored;
                            },
                            child: TextField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white10,
                                counterText: '',
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(color: Colors.white, fontSize: 24),
                              onChanged: (val) {
                                setState(() {});
                                if (val.isNotEmpty) {
                                  if (index < 5) {
                                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      }),
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
                                await vm.validateOtp(widget.organizationId, otpCode);
                                if (vm.success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChangePasswordScreen(
                                        organizationId: widget.organizationId,
                                        code: otpCode,
                                        // organizationId: 1234,
                                        // code: '123456',
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Error Message for verification
                    if (vm.errorMessage != null)
                      Text(vm.errorMessage!, style: TextStyle(color: Colors.redAccent)),

                    SizedBox(height: 20),

                    // Resend OTP message
                    if (vm.resendMessage != null)
                      Text(vm.resendMessage!, style: TextStyle(color: Colors.greenAccent)),

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
                              await vm.resendCode(widget.organizationId, widget.email);
                            }
                          : null,
                      icon: Icon(Icons.refresh, color: (resendAvailable && !vm.isResending) ? Colors.blueAccent : Colors.grey),
                      label: vm.isResending
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent),
                            )
                          : Text(
                              'Resend code',
                              style: TextStyle(color: (resendAvailable && !vm.isResending) ? Colors.blueAccent : Colors.grey),
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
    controllers.forEach((c) => c.dispose());
    focusNodes.forEach((f) => f.dispose());
    timer.cancel();
    super.dispose();
  }
}

/// Custom Step Indicator widget with connecting vertical line
class StepIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isLast;

  StepIndicator({required this.label, this.isActive = false, this.isLast = false});

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
