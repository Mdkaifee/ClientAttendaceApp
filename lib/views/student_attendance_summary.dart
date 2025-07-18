import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_attendance_summary_viewmodel.dart';

class StudentAttendanceSummaryScreen extends StatelessWidget {
  final String token;
  final int studentId;
  final String attendanceTakenDate;

  const StudentAttendanceSummaryScreen({
    required this.token,
    required this.studentId,
    required this.attendanceTakenDate,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentAttendanceSummaryViewModel()..fetchSummary(token,studentId, attendanceTakenDate),
      child: Consumer<StudentAttendanceSummaryViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return Scaffold(
              backgroundColor: Color(0xFF0B1E3A),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              backgroundColor: Color(0xFF0B1E3A),
              body: Center(child: Text(vm.error!, style: TextStyle(color: Colors.white))),
            );
          }
          if (vm.summary == null) {
            return Scaffold(
              backgroundColor: Color(0xFF0B1E3A),
              body: Center(child: Text("No data found.", style: TextStyle(color: Colors.white))),
            );
          }

          final student = vm.summary!;

          return Scaffold(
            backgroundColor: Color(0xFF0B1E3A),
            appBar: AppBar(
              title: Text('Student Summary'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blueGrey,
                      backgroundImage: student.photoUrl != null && student.photoUrl!.isNotEmpty
                          ? NetworkImage("https://attendanceapiuat.massivedanamik.com/resources/${student.photoUrl}")
                          : null,
                      child: (student.photoUrl == null || student.photoUrl!.isEmpty)
                          ? Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      "${student.firstName} ${student.lastName}",
                      style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Email: ${student.email ?? '-'}", style: TextStyle(color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Phone: ${student.phone ?? '-'}", style: TextStyle(color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Address: ${student.addressLine1 ?? '-'}", style: TextStyle(color: Colors.white)),
                  SizedBox(height: 8),
                  Text("Postal Code: ${student.postalCode ?? '-'}", style: TextStyle(color: Colors.white)),
                  SizedBox(height: 16),
                  // TODO: Add calendarMonthAttendanceDetail or summaries as needed
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
