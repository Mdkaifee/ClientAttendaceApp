import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/login_viewmodel.dart';
import 'register_select_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final orgController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = false;
  bool _initialized = false;
  bool _obscurePassword = true;
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load saved credentials
  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        orgController.text = prefs.getString('orgId') ?? '';
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      }
      _initialized = true;
    });
  }

  // Save or remove credentials
  Future<void> _handleRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setBool('rememberMe', true);
      await prefs.setString('orgId', orgController.text);
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
    } else {
      await prefs.setBool('rememberMe', false);
      await prefs.remove('orgId');
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      // Show splash/loading while loading prefs
      return Scaffold(
        backgroundColor: Color(0xFF162244),
        body: Center(child: CircularProgressIndicator()),
      );
    }

   return ChangeNotifierProvider(
    create: (_) => LoginViewModel(),
    child: Consumer<LoginViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: Color(0xFF162244),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/logo.png", width: 80),
                  SizedBox(height: 32),
                  Text('Sign in', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  // ----- INFO BOX -----
                  Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFF6CA0FF).withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF6CA0FF), width: 1),
                    ),
                    child: Text(
                      "You are browsing Massive Dynamic.\nClick on \"Sign in\" to access the features or \"Sign up\" if you don't have an account.",
                      style: TextStyle(color: Color(0xFFB4C9F9), fontSize: 15.5, height: 1.4),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Organisation Number
                  TextField(
                    controller: orgController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      labelText: "Organisation Number *",
                      hintText: "EX: 1234",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 12),

                  // Email Address
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      labelText: "Email Address *",
                      hintText: "EX: WilliamGoldsmith@DGS.ac.uk",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 12),

                  // PASSWORD with SHOW/HIDE
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      labelText: "Password *",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    obscureText: _obscurePassword,
                  ),
                  SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (val) {
                                setState(() {
                                  rememberMe = val ?? false;
                                });
                              },
                              activeColor: Colors.blue,
                            ),
                            Text("Remember me", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text("Forgot Password?", style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    if (vm.errorMessage != null)
                      Text(vm.errorMessage!, style: TextStyle(color: Colors.redAccent)),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: vm.isLoading
    ? null
    : () async {
        await _handleRememberMe();
        bool success = await vm.login(
          emailController.text,
          passwordController.text,
          orgController.text,
        );
        if (success && vm.user != null && vm.user!.accessToken.isNotEmpty) {
          // Navigator.pushReplacementNamed(
          //   context,
          //   '/attendance',
          //   arguments: vm.user!.accessToken, // Pass token as an argument
          // );
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegisterSelectScreen(
              token: vm.user!.accessToken,
              tuitionCentreName: vm.user!.educationCentreName,
            ),
            ),
          );
          }
        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: vm.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text("Sign in", style: TextStyle(fontSize: 18)),
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
