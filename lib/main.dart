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
          // Expecting arguments as a Map to hold all required params
          final args = settings.arguments as Map<String, dynamic>?;

          if (args == null) {
            // Handle error or redirect
            return MaterialPageRoute(builder: (context) => LoginScreen());
          }

          return MaterialPageRoute(
            builder: (context) => AttendanceScreen(
              token: args['token'] as String,
              classId: args['classId'] as int,
              attendanceTakenDate: args['attendanceTakenDate'] as String,
              calendarModelId: args['calendarModelId'] as int,
              tuitionCentreName: args['tuitionCentreName'] as String,
              selectedYearGroupName: args['selectedYearGroupName'] as String,
              // Add this
              selectedPeriod: args['selectedPeriod'] as String,
              organizationId: args['organizationId'] as int,
              // Add these
              tuitionCentreId: args['tuitionCentreId'] as int,
              educationCentreId: args['educationCentreId'] as int,
            ),
          );
        }
        return null;
      },
    );
  }
}
