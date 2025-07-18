import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/change_password_viewmodel.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int organizationId;
  final String code;

  ChangePasswordScreen({required this.organizationId, required this.code});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChangePasswordViewModel(),
      child: Consumer<ChangePasswordViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: Color(0xFF162244),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/logo.png", width: 80),
                  SizedBox(height: 20),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Create a new password that meets the following requirements:\n'
                    '1) Should be alpha-numeric\n'
                    '2) At least one special character (%@_)\n'
                    '3) Minimum 8 characters',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  SizedBox(height: 24),

                    // Step Indicators with connecting lines
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StepIndicator(label: 'Submit email address', isActive: false, isLast: false),
                        StepIndicator(label: 'Enter verification code', isActive: false, isLast: false),
                        StepIndicator(label: 'Change password', isActive: true, isLast: false),
                        StepIndicator(label: 'Login again', isActive: false, isLast: true),
                      ],
                    ),

                    SizedBox(height: 24),

                  // Password TextField
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),

                  // Confirm Password TextField
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: 'Confirm Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),

                  if (vm.errorMessage != null)
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(vm.errorMessage!, style: TextStyle(color: Colors.redAccent)),
                    ),

                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: vm.isLoading
                          ? null
                          : () async {
                              // Passwords must match first
                              if (passwordController.text != confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Passwords don't match")),
                                );
                                return;
                              }

                              // Validate password criteria here (optional, can be in VM)
                              final password = passwordController.text;
                              final pattern = RegExp(r'^(?=.*[a-zA-Z0-9])(?=.*[%@_])[a-zA-Z0-9%@_]{8,}$');
                              if (!pattern.hasMatch(password)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Password does not meet the criteria")),
                                );
                                return;
                              }

                              // Call reset password API
                              await vm.resetPassword(
                                organizationId: widget.organizationId,
                                code: widget.code,
                                newPassword: password,
                              );

                              // On success navigate back to login or wherever needed
                              if (vm.success) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Password changed successfully")),
                                  );
                                  Navigator.popUntil(context, (route) => route.isFirst);
                                }
                              }
                            },
                      child: vm.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Confirm changes', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
                height: 28,            // Reduced height from 40 to 28
                color: Colors.white38,
                margin: EdgeInsets.only(top: 1),  // Reduced top margin from 2 to 1
              ),
          ],
        ),
        SizedBox(width: 4),           // Reduced width from 8 to 4
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
