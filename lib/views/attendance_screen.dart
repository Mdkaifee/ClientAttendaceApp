import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/attendance_viewmodel.dart';
import 'register_select_screen.dart'; // Adjust path if needed
import 'student_attendance_summary.dart';
import '../models/attendance_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../services/network_service.dart';
import 'login_screen.dart';
class AttendanceScreen extends StatefulWidget {
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
  _AttendanceScreenState createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<AttendanceScreen> {
  final Map<String, String> markCodeMap = {};
  Map<String, Uint8List?> _photoCache = {};

Uint8List decodeBase64Image(String base64String) {
  return base64Decode(base64String.split(',').last);
}
Future<Uint8List?> fetchStudentPhoto(String token, int studentId, String fileName) async {
  String cacheKey = "$studentId|$fileName";
  if (_photoCache.containsKey(cacheKey)) {
    // ✅ Even if null, return (to avoid re-fetch)
    return _photoCache[cacheKey];
  }

  final url = Uri.parse('https://adminapiuat.massivedanamik.com/api/GetStudentPhotoAsByteArrayAsync?studentId=$studentId&fileName=$fileName');
  final response = await http.post(url, headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    Uint8List imgBytes;
    if (data is Map && data.containsKey('photo')) {
      imgBytes = decodeBase64Image(data['photo']);
    } else {
      imgBytes = decodeBase64Image(data);
    }
    _photoCache[cacheKey] = imgBytes;
    return imgBytes;
  } else {
    // ⬇️ Cache "null" so next time it doesn't refetch
    _photoCache[cacheKey] = null;
    return null;
  }
}


Future<void> _showConfirmationDialog(BuildContext context, AttendanceViewModel vm) async {
  // Show the confirmation dialog and wait for response
  bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Submission'),
        content: Text('Are you sure you wish to submit?'),
        actions: <Widget>[
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);  // Close dialog and return false
            },
            child: Text('Cancel'),
          ),
          // Confirm button
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);  // Close dialog and return true
            },
            child: Text('Yes'),
          ),
        ],
      );
    },
  );

  // If the user cancels, exit early
  if (confirm == null || !confirm) {
    return;
  }

  // Proceed with the API call and navigate only if successful
  final success = await vm.submitAttendanceRegister(
    token: widget.token,
    calendarModelId: widget.calendarModelId,
    educationCentreClassId: widget.classId,
  );

  print("API success: $success");

  // Check if the widget is still mounted before showing the SnackBar
  if (mounted) {
    if (success) {
      print("Widget is still mounted, showing SnackBar...");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student Attendance Register updated successfully.')),
      );

      // Use Future.delayed to ensure the navigation occurs after the SnackBar
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          print("Navigating to RegisterSelectScreen...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => RegisterSelectScreen(
                token: widget.token,
                tuitionCentreName: widget.tuitionCentreName,
                organizationId: widget.organizationId,
                tuitionCentreId: widget.tuitionCentreId,
                educationCentreId: widget.educationCentreId,
              ),
            ),
          );
        }
      });
    } else {
      print("Widget is no longer mounted, skipping navigation.");
      // Show failure message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit attendance register!')),
      );
    }
  }
}
Widget _buildMarkButton(student, AttendanceViewModel vm) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: student.markCodeId == '1042' || student.isMarked
          ? Colors.grey
          : Color(0xFF1F4F91),
    ),
    child: PopupMenuButton<String>(
      enabled: !student.isMarked,
      onSelected: (value) {
        if (!student.isMarked) {
          setState(() {
            student.markCodeId = value;

            final selectedMarkCode = vm.markCodes.firstWhere(
              (code) => code['id'].toString() == value,
              orElse: () => null,
            );

            student.markCodeName = selectedMarkCode?['name'];

            print('Selected mark code name: ${student.markCodeName}');

            if (student.markCodeId == '1040') {
              // Present – call API immediately
              student.lateMinutes = "0";
              vm.markStudent(student, student.markSubCodeId).then((success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Attendance for ${student.studentName} updated successfully.'
                          : 'Failed to update attendance for ${student.studentName}.',
                    ),
                  ),
                );
              });
            } else if (student.markCodeId == '1043') {
              // Present but Late – wait for user to enter minutes
              student.lateMinutes = ''; // Clear field to force input
              // No API call here
            } else if (student.markCodeId != '1042') {
              // Other types (if any) can call API here
              vm.markStudent(student, student.markSubCodeId).then((success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Attendance for ${student.studentName} updated successfully.'
                          : 'Failed to update attendance for ${student.studentName}.',
                    ),
                  ),
                );
              });
            }
          });
        }
      },
      itemBuilder: (context) {
        return vm.markCodes.map((code) {
          return PopupMenuItem<String>(
            value: code['id'].toString(),
            child: Text(code['description']),
          );
        }).toList();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: SizedBox(
          width: 80,
          child: Center(
            child: Text(
              student.markCodeId == '1043'
                  ? 'Present but Late'
                  : student.markCodeId == '1042'
                      ? 'Absent'
                      : student.markCodeId == '1040'
                          ? 'Present'
                          : 'Mark',
              style: TextStyle(color: Colors.white, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildSubMarkButton(student, AttendanceViewModel vm) {
  return ElevatedButton(
        onPressed: student.isMarked || student.markCodeId != '1042'
      ? null
      : () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: student.markCodeId == '1042' && !student.isMarked
        ? Color(0xFF1F4F91)
        : Colors.grey,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
    elevation: 0,
  ),
  child: PopupMenuButton<String>(
    onSelected: (value) {
      if (!student.isMarked) {
        setState(() {
          final selectedSubCode = vm.markSubCodes.firstWhere(
            (subCode) => subCode['description'] == value, 
            orElse: () => null
          );
          student.markSubCodeId = selectedSubCode != null ? selectedSubCode['id'].toString() : 'Unknown';
          student.markSubCodeDescription = selectedSubCode != null ? selectedSubCode['description'] : 'Unknown';

          // Log the selected subCode details
          print('Selected SubCode ID: ${student.markSubCodeId}');
          print('Selected SubCode Description: ${student.markSubCodeDescription}');

          // Call the markStudent method to save attendance
          vm.markStudent(student, student.markSubCodeId).then((success) {
            if (success) {
              // If API response is success, show SnackBar with student's name
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Attendance for ${student.studentName} updated successfully.')),
              );
            } else {
              // Handle API failure here (optional)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update attendance for ${student.studentName}.')),
              );
            }
          });
        });
      }
    },
    itemBuilder: (context) {
      if (student.markCodeId == '1042' && !student.isMarked) {
        return vm.markSubCodes.map((subCode) {
          return PopupMenuItem<String>(
            value: subCode['description'].toString(),
            child: Text(subCode['description']),
          );
        }).toList();
      } else {
        return [];
      }
    },

    child: SizedBox(
width: 80, // ✅ Fixed width
 child: Center( 
child: Text(
  student.markSubCodeDescription ?? 'Sub-Mark',
  style: TextStyle(color: Colors.white, fontSize: 12),
  maxLines: 1,
  overflow: TextOverflow.ellipsis, // ✅ Ellipsis for long text
),
),
    ),
  ),
  );
}

Widget _buildLateInputField(student, AttendanceViewModel vm) {
  final controller = TextEditingController(text: student.lateMinutes ?? '');
  controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

  return Container(
    width: 60,
    height: 36,
    padding: EdgeInsets.symmetric(horizontal: 5),
    decoration: BoxDecoration(
      color: Color(0xFF16345E),
      borderRadius: BorderRadius.circular(8),
    ),
    child: TextField(
      enabled: student.markCodeId == '1043' && !student.isMarked,
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
      controller: controller,
      onChanged: (val) {
        if (!student.isMarked && student.markCodeId == '1043') {
          student.lateMinutes = val;
        }
      },
      onSubmitted: (val) {
        if (!student.isMarked &&
            student.markCodeId == '1043' &&
            val.isNotEmpty &&
            int.tryParse(val) != null) {
          student.lateMinutes = val;
          vm.markStudent(student, student.markSubCodeId).then((success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Attendance for ${student.studentName} updated successfully.'
                      : 'Failed to update attendance for ${student.studentName}.',
                ),
              ),
            );
          });
        }
      },
    ),
  );
}


  @override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => AttendanceViewModel()
      ..loadAttendance(
        token: widget.token,
        classId: widget.classId,
        attendanceTakenDate: widget.attendanceTakenDate,
        calendarModelId: widget.calendarModelId,
      ),
    child: Consumer<AttendanceViewModel>(builder: (context, vm, _) {
      if (vm.isLoading) {
        return Scaffold(
          backgroundColor: Color(0xFF0B1E3A),
          body: Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        );
      }

      if (vm.error != null) {
    // Check if the error message indicates token expiration
    if (vm.error!.toLowerCase().contains("token expired") || vm.error!.toLowerCase().contains("no data found")) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to LoginScreen
            );
        });
    }
    return Scaffold(
        backgroundColor: Color(0xFF0B1E3A),
        body: Center(child: Text(vm.error!, style: TextStyle(color: Colors.white))),
    );
}



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
                    Text('Input the attendance for your class below', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              children: [
                // Search and Sort Row
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
                          items: ["default", "mark code asc", "mark code desc"]
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

                // Year Group and Period Buttons
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
                                  token: widget.token,
                                  tuitionCentreName: widget.tuitionCentreName,
                                  organizationId: widget.organizationId,
                                  tuitionCentreId: widget.tuitionCentreId,
                                  educationCentreId: widget.educationCentreId,
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
                            widget.selectedYearGroupName,
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
                            widget.selectedPeriod,
                            style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                         SizedBox(width: 8),
                   TextButton(
  onPressed: () {
    _showConfirmationDialog(context, vm);
  },
  style: TextButton.styleFrom(
    backgroundColor: Color(0xFF5D99F6), // Same color as the other buttons
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    minimumSize: Size(0, 0),
  ),
  child: Text(
    'Submit',
    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
    overflow: TextOverflow.ellipsis,
  ),
),

                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Attendance Header Row
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Student', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(child: Text('Mark', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                      ),
                      Expanded(
                        flex: 3,
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
              Expanded(
          child: vm.filteredStudents.isEmpty
              ? Center(
                  child: Text(
                    'No student found for this match',
                    style: TextStyle(color: Colors.white60, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: vm.filteredStudents.length + 1,
                  itemBuilder: (context, index) {
                    if (index < vm.filteredStudents.length) {
                      final student = vm.filteredStudents[index];
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                             if (!await NetworkService().isConnected()) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('No Internet Connection')),
                                        );
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StudentAttendanceSummaryScreen(
                                            token: widget.token,
                                            studentId: student.studentId,
                                            attendanceTakenDate: widget.attendanceTakenDate,
                                            selectedYearGroupName: widget.selectedYearGroupName,
                                            selectedPeriod: widget.selectedPeriod,
                                            tuitionCentreName: widget.tuitionCentreName,
                                            photoUrl: student.avatarUrl,
                                          ),
                                        ),
                                      );
                                    },
                     child:FutureBuilder<Uint8List?>(
																						future: fetchStudentPhoto(widget.token, student.studentId, student.avatarUrl),
  // future: fetchStudentPhoto(widget.token, student.studentId, student.avatarUrl),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey.shade800,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (snapshot.hasData && snapshot.data != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: MemoryImage(snapshot.data!), // ✅ Image loaded from bytes
        backgroundColor: Colors.transparent,
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage('assets/default_avatar.png'), // Fallback image
        backgroundColor: Colors.transparent,
      );
    }
  },
),

                                        ),
                                        SizedBox(width: 32),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.studentName,
                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                                SizedBox(height: 8),

                  // ⬇️ Second Row: Mark | Sub-Mark | Late
                  Row(
                    children: [
                      // 🔷 MARK
                      _buildMarkButton(student, vm),
                      SizedBox(width:15),

                      // 🔷 SUB-MARK
                      _buildSubMarkButton(student, vm),
                      SizedBox(width:20),

                      // 🔷 LATE INPUT
                      _buildLateInputField(student, vm),
                    ],
                  )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                              ],
                                            ),
                                          );
                                        }else {
                                            // LAST ITEM: THE SUBMIT BUTTON
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () => _showConfirmationDialog(context, vm),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.blueAccent,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                                  ),
                                                  child: Text(
                                                    'Submit Attendance',
                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                        ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
              ],
            ),
          ),
        );
      }),
    );
  }
}