import 'package:flutter/material.dart';
import 'views/login_screen.dart';
import 'views/attendance_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Client',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => LoginScreen());
        }
        if (settings.name == '/attendance') {
          final token = settings.arguments as String; // <- gets the token!
          return MaterialPageRoute(
            builder: (context) => AttendanceScreen(token: token),
          );
        }
        return null;
      },
    );
  }
}
