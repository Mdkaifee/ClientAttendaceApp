import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final int organizationId;

  const ForgotPasswordScreen({Key? key, required this.organizationId})
    : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String? localError;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordViewModel(),
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Color(0xFF162244),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 32,
                  right: 32,
                  top: 12,
                  bottom: 34,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo + Titles Left Aligned
                    Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset("assets/logo.png", width: 80),
                          SizedBox(height: 8),
                          Text(
                            'Forgot password',
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Enter your email address and we'll\nsend you a verification code to your\nregistered email address.",
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
                          isActive: true,
                          isLast: false,
                        ),
                        StepIndicator(
                          label: 'Enter verification code',
                          isActive: false,
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

                    // Email Input Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white10,
                        hintText: 'Email Address',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      onChanged: (_) {
                        if (localError != null)
                          setState(() => localError = null);
                      },
                    ),

                    if (localError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          localError!,
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),

                    SizedBox(height: 24),

                    // Send Email Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: vm.isLoading
                            ? null
                            : () {
                                if (emailController.text.trim().isEmpty) {
                                  setState(() {
                                    localError = "Please enter your email";
                                  });
                                  return;
                                }
                                setState(() {
                                  localError = null;
                                });
                                vm.sendResetCode(
                                  // widget.organizationId,
                                  email: emailController.text,
                                );
                              },
                        child: vm.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Send email',
                                style: TextStyle(fontSize: 18),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    if (vm.errorMessage != null)
                      Text(
                        vm.errorMessage!,
                        style: TextStyle(color: Colors.redAccent),
                      ),

                    if (vm.success)
                      Builder(
                        builder: (context) {
                          Future.microtask(() {
                            if (ModalRoute.of(context)?.isCurrent ?? false) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OtpVerificationScreen(
                                    organizationId: widget.organizationId,
                                    email: emailController.text,
                                  ),
                                ),
                              );
                              vm.clearSuccess();
                            }
                          });
                          return Container();
                        },
                      ),

                    SizedBox(height: 20),

                    TextButton(
                      onPressed: vm.isLoading
                          ? null
                          : () {
                              if (emailController.text.trim().isEmpty) {
                                setState(() {
                                  localError = "Please enter your email";
                                });
                                return;
                              }
                              setState(() {
                                localError = null;
                              });
                              vm.sendResetCode(
                                // widget.organizationId,
                                email: emailController.text,
                                isResend: true,
                              );
                            },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t get the email?',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.refresh, color: Colors.blue, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Resend',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Back to sign in',
                        style: TextStyle(color: Colors.blue),
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
}

/// Custom Step Indicator widget with connecting vertical line
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
                height: 28, // Reduced height from 40 to 28
                color: Colors.white38,
                margin: EdgeInsets.only(
                  top: 1,
                ), // Reduced top margin from 2 to 1
              ),
          ],
        ),
        SizedBox(width: 4), // Reduced width from 8 to 4
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
