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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _strengthAdvice;
  Color _strengthColor = Colors.red;
  double _strengthPercent = 0.0;
  bool _isPasswordStrongEnough = false;
  String? _passwordError;

  String? _successMessage;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_checkPasswordStrength);
    _checkPasswordStrength();
  }

  void _checkPasswordStrength() {
    final password = passwordController.text;

    // Criteria:
    // 1) Alpha-numeric (contains letters and numbers)
    // 2) At least one special character from (% @ _)
    // 3) Minimum 8 characters

    bool hasAlpha = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[%@_]'));
    bool isLongEnough = password.length >= 8;

    // Check unmet rules for error text
    List<String> unmetRules = [];
    if (!hasAlpha) unmetRules.add("at least one letter");
    if (!hasNumber) unmetRules.add("at least one number");
    if (!hasSpecial) unmetRules.add("at least one special character (%@_)");
    if (!isLongEnough) unmetRules.add("minimum 8 characters");

    if (unmetRules.isNotEmpty) {
      _passwordError = "You must use " + unmetRules.join(", ");
      _strengthColor = Colors.red;
      _strengthPercent = 0.33;
      _strengthAdvice = null;
      _isPasswordStrongEnough = false;
    } else {
      _passwordError = null;

      // Evaluate strength further - e.g. presence of uppercase letter
      bool hasUpper = password.contains(RegExp(r'[A-Z]'));

      if (hasUpper && password.length >= 12) {
        // Strong password
        _strengthColor = Colors.green;
        _strengthPercent = 1.0;
        _strengthAdvice = null;
        _isPasswordStrongEnough = true;
      } else {
        // Medium strength - amber
        _strengthColor = Colors.amber;
        _strengthPercent = 0.66;
        _strengthAdvice = "Password could be better but still be used";
        _isPasswordStrongEnough = true; // still acceptable to use
      }
    }

    setState(() {});
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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
                  if (_successMessage != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _successMessage!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
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
                      StepIndicator(
                        label: 'Submit email address',
                        isActive: false,
                        isLast: false,
                      ),
                      StepIndicator(
                        label: 'Enter verification code',
                        isActive: false,
                        isLast: false,
                      ),
                      StepIndicator(
                        label: 'Change password',
                        isActive: true,
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

                  // Password TextField
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),

                  SizedBox(height: 16),
                  // Password strength meter bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 18, // Increased height for thicker meter bar
                      child: LinearProgressIndicator(
                        value: _strengthPercent,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _strengthColor,
                        ),
                      ),
                    ),
                  ),

                  // Spacing below meter
                  SizedBox(height: 6),

                  // Password error or advice text
                  if (_passwordError != null)
                    Text(
                      _passwordError!,
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    )
                  else if (_strengthAdvice != null)
                    Text(
                      _strengthAdvice!,
                      style: TextStyle(color: Colors.amberAccent, fontSize: 13),
                    )
                  else if (_strengthColor == Colors.green)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'The password is strong and meets all the requirements',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),

                  SizedBox(height: 24),
                  if (vm.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        vm.errorMessage!,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: vm.isLoading || !_isPasswordStrongEnough
                          ? null
                          : () async {
                              // Passwords must match first
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Passwords don't match"),
                                  ),
                                );
                                return;
                              }

                              // Call reset password API
                              await vm.resetPassword(
                                organizationId: widget.organizationId,
                                code: widget.code,
                                newPassword: passwordController.text,
                              );

                              // On success navigate back to login or wherever needed
                              if (vm.success) {
                                if (mounted) {
                                  setState(() {
                                    _successMessage =
                                        "Password changed successfully!";
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Password changed successfully",
                                      ),
                                    ),
                                  );
                                  // Optional delay before navigating away to show success message
                                  await Future.delayed(Duration(seconds: 1));
                                  Navigator.popUntil(
                                    context,
                                    (route) => route.isFirst,
                                  );
                                }
                              }
                            },
                      child: vm.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Confirm changes',
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
