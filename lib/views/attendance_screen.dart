import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/attendance_viewmodel.dart';
import 'register_select_screen.dart';  // Adjust path if needed
import 'student_attendance_summary.dart';

class AttendanceScreen extends StatelessWidget {
  final String token;
  final int classId;
  final String attendanceTakenDate;
  final int calendarModelId;
  final String tuitionCentreName;
  final String selectedYearGroupName;
  final String selectedPeriod;
  final int organizationId;
  final int tuitionCentreId;
  final int educationCentreId;

  AttendanceScreen({
    required this.token,
    required this.classId,
    required this.attendanceTakenDate,
    required this.calendarModelId,
    required this.tuitionCentreName,
    required this.selectedYearGroupName,
    required this.selectedPeriod,
    required this.organizationId,
    required this.tuitionCentreId,
    required this.educationCentreId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceViewModel()
        ..loadAttendance(
          token: token,
          classId: classId,
          attendanceTakenDate: attendanceTakenDate,
          calendarModelId: calendarModelId,
        ),
      child: Consumer<AttendanceViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return Scaffold(
              backgroundColor: Color(0xFF0B1E3A),
              body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
            );
          }
          if (vm.error != null) {
            return Scaffold(
              backgroundColor: Color(0xFF0B1E3A),
              body: Center(child: Text(vm.error!, style: TextStyle(color: Colors.white))),
            );
          }

          // Sort options
          final sortOptions = ["default", "mark code asc", "mark code desc"];

          return Scaffold(
            backgroundColor: Color(0xFF0B1E3A),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              title: Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 120,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      SizedBox(height: 4),
                      Text('input the attendance for your class below', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  // Search & Sort row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(0xFF16345E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              icon: Icon(Icons.search, color: Colors.white54),
                              hintText: 'Search',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            onChanged: (val) {
                              vm.searchQuery = val;
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        height: 36,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF16345E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: vm.selectedSortOption,
                            dropdownColor: Color(0xFF16345E),
                            iconEnabledColor: Colors.white,
                            items: sortOptions
                                .map((val) => DropdownMenuItem(
                                      value: val,
                                      child: Text(val, style: TextStyle(color: Colors.white)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                vm.selectedSortOption = val;
                                vm.sortStudents();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.only(right: 40),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RegisterSelectScreen(
                                    token: token,
                                    tuitionCentreName: tuitionCentreName,
                                    organizationId: organizationId,
                                    tuitionCentreId: tuitionCentreId,
                                    educationCentreId: educationCentreId,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFF5D99F6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            icon: Icon(Icons.arrow_back, color: Colors.black, size: 20),
                            label: Text(
                              'Back',
                              style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(width: 44),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFF5D99F6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              minimumSize: Size(0, 0),
                            ),
                            child: Text(
                              selectedYearGroupName,
                              style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFF5D99F6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              minimumSize: Size(0, 0),
                            ),
                            child: Text(
                              selectedPeriod,
                              style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text('Student', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: Text('Mark', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: Text('Sub-Mark', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(child: Text('Late', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),

                  // ... keep all the previous code above unchanged ...

Expanded(
  child: vm.filteredStudents.isEmpty
      ? Center(
          child: Text(
            "No students found related to this search.",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        )
      : ListView.builder(
          itemCount: vm.filteredStudents.length,
          itemBuilder: (context, index) {
            final student = vm.filteredStudents[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // ... Avatar + Name ...
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentAttendanceSummaryScreen(
                                  token: token,
                                  studentId: student.studentId,
                                  attendanceTakenDate: attendanceTakenDate,
                                  selectedYearGroupName: selectedYearGroupName,
                                  selectedPeriod: selectedPeriod,
                                  tuitionCentreName: tuitionCentreName,
                                ),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey.shade800,
                            backgroundImage: student.avatarUrl.isNotEmpty
                                ? NetworkImage(student.avatarUrl)
                                : null,
                            child: student.avatarUrl.isEmpty
                                ? Icon(Icons.person, color: Colors.white54, size: 24)
                                : null,
                          ),
                        ),
                        SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.studentName,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // MARK BUTTON
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: (student.markCodeId != null && student.markCodeId!.isNotEmpty)
                            ? null // Disabled if marked
                            : () async {
                                final success = await vm.markStudent(
                                  token: token,
                                  classId: classId,
                                  calendarModelId: calendarModelId,
                                  educationCentreClassIdDesc: tuitionCentreName,
                                  student: student,
                                  markCodeId: "1040", // Main Mark code
                                );
                                if (success) {
                                  // Clear late input on mark
                                  student.lateMinutes = '';
                                  vm.notifyListeners(); // This is needed so that UI reflects the empty field
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? 'Marked present for ${student.studentName}!'
                                        : 'Failed to mark. Try again.'),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1F4F91),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          elevation: 0,
                        ),
                        child: Text(
                          (student.markCodeId != null && student.markCodeId!.isNotEmpty)
                              ? 'Marked'
                              : 'Mark',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  // SUB-MARK BUTTON
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: (student.markSubCodeId != null && student.markSubCodeId!.isNotEmpty)
                            ? null
                            : () async {
                                final success = await vm.markStudent(
                                  token: token,
                                  classId: classId,
                                  calendarModelId: calendarModelId,
                                  educationCentreClassIdDesc: tuitionCentreName,
                                  student: student,
                                  markCodeId: "1041", // Sub-mark code example
                                );
                                if (success) {
                                  // Clear late input on sub-mark
                                  student.lateMinutes = '';
                                  vm.notifyListeners();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? 'Sub-marked for ${student.studentName}!'
                                        : 'Failed to sub-mark. Try again.'),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1F4F91),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          elevation: 0,
                        ),
                        child: Text(
                          (student.markSubCodeId != null && student.markSubCodeId!.isNotEmpty)
                              ? 'Marked'
                              : 'Mark',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  // LATE INPUT
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 36,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF16345E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Late',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: student.lateMinutes,
                        ),
                        onChanged: (val) {
                          student.lateMinutes = val;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
),
                  SizedBox(height: 16),
                  // Submit button does nothing
                  SizedBox(
  width: double.infinity,
  height: 48,
  child: ElevatedButton(
    onPressed: () async {
      final success = await vm.submitAttendanceRegister(
        token: token,
        calendarModelId: calendarModelId,
        educationCentreClassId: classId, // Assuming your classId is EducationCentreClassId, update if different
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student Attendance Register updated successfully.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit attendance register!')),
        );
      }
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blueAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    child: Text(
      'Submit',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  ),
),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
