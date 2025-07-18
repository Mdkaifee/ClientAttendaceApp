import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_attendance_summary_viewmodel.dart';
import 'attendance_screen.dart'; // for back navigation

class StudentAttendanceSummaryScreen extends StatelessWidget {
  final String token;
  final int studentId;
  final String attendanceTakenDate;
  final String selectedYearGroupName;
  final String selectedPeriod;

  const StudentAttendanceSummaryScreen({
    required this.token,
    required this.studentId,
    required this.attendanceTakenDate,
    required this.selectedYearGroupName,
    required this.selectedPeriod,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentAttendanceSummaryViewModel()
        ..fetchSummary(token, studentId, attendanceTakenDate),
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
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Top row with logo and back button ---
                    Row(
                      children: [
                        // Logo (top-left)
                        Image.asset(
                          'assets/logo.png',  // <-- Replace with your actual logo path
                          width: 80,
                          height: 80,
                        ),
                        Spacer(),
                        // Back button (icon + text)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            // Or if you want to always go to AttendanceScreen:
                            // Navigator.pushReplacement(context, MaterialPageRoute(
                            //   builder: (_) => AttendanceScreen(
                            //     token: token,
                            //     classId: ..., // pass all required args
                            //     attendanceTakenDate: attendanceTakenDate,
                            //     calendarModelId: ...,
                            //     tuitionCentreName: ...,
                            //     selectedYearGroupName: selectedYearGroupName,
                            //     selectedPeriod: selectedPeriod,
                            //   ),
                            // ));
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color(0xFF102C52), // subtle dark blue
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          ),
                          icon: Icon(Icons.arrow_back, color: Colors.blueAccent, size: 20),
                          label: Text(
                            "Back",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // --- Profile avatar and name ---
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.blueGrey[600],
                        backgroundImage: student.photoUrl != null && student.photoUrl!.isNotEmpty
                            ? NetworkImage("https://attendanceapiuat.massivedanamik.com/resources/${student.photoUrl}")
                            : null,
                        child: (student.photoUrl == null || student.photoUrl!.isEmpty)
                            ? Icon(Icons.person, size: 52, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(height: 18),

                    // --- Student Name ---
                    Center(
                      child: Text(
                        "${student.firstName} ${student.lastName}",
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 14),

                    // --- Pills: School, Year, Period ---
                    SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: [
      Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF5D99F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          'Dynamics school', // Or pass as param if dynamic
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF5D99F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          selectedYearGroupName,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF5D99F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          selectedPeriod,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    ],
  ),
),

                    SizedBox(height: 24),

                    // --- Info Card (Student Address, Parent Number, Notes) ---
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Student Address:  ${student.addressLine1 ?? '-'}",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Parents number: ${student.phone ?? '-'}",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Additional notes: N/A", // Update as needed if notes are available
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    // ...Add more widgets as needed...
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
