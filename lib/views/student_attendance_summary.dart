import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_attendance_summary_viewmodel.dart';

class StudentAttendanceSummaryScreen extends StatelessWidget {
  final String token;
  final int studentId;
  final String attendanceTakenDate;
  final String selectedYearGroupName;
  final String selectedPeriod;
  final String tuitionCentreName;

  const StudentAttendanceSummaryScreen({
    required this.token,
    required this.studentId,
    required this.attendanceTakenDate,
    required this.selectedYearGroupName,
    required this.selectedPeriod,
    required this.tuitionCentreName,
    Key? key,
  }) : super(key: key);

  // Utility for getting the current month/year from attendanceTakenDate (yyyy-MM-dd)
  String getMonthYear(String attendanceTakenDate) {
    try {
      final date = DateTime.parse(attendanceTakenDate);
      return "${_monthName(date.month)} ${date.year}";
    } catch (_) {
      return attendanceTakenDate;
    }
  }

  static String _monthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }

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
          final month = getMonthYear(attendanceTakenDate);

          return Scaffold(
            backgroundColor: Color(0xFF0B1E3A),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo + Back
                      Row(
                        children: [
                          Image.asset('assets/logo.png', width: 80, height: 80),
                          Spacer(),
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                            ),
                            icon: Icon(Icons.arrow_back, color: Colors.blueAccent, size: 22),
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
                      SizedBox(height: 10),

                      // Profile avatar and name
                      Center(
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.blueGrey[600],
                          backgroundImage: student.photoUrl != null && student.photoUrl!.isNotEmpty
                              ? NetworkImage("https://attendanceapiuat.massivedanamik.com/resources/${student.photoUrl}")
                              : null,
                          child: (student.photoUrl == null || student.photoUrl!.isEmpty)
                              ? Icon(Icons.person, size: 44, color: Colors.white)
                              : null,
                        ),
                      ),
                      SizedBox(height: 14),

                      Center(
                        child: Text(
                          "${student.firstName} ${student.lastName}",
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(height: 14),

                      // Pills: School, Year, Period (all scrollable)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _pill(tuitionCentreName),
                            SizedBox(width: 10),
                            _pill(selectedYearGroupName),
                            SizedBox(width: 10),
                            _pill(selectedPeriod),
                          ],
                        ),
                      ),

                      SizedBox(height: 18),

                      // Info card
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
                              "Additional notes: N/A", // Make dynamic if you have notes
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18),

                      // Calendar Section
                      Text(
                        month,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      _CustomCalendar(
                        calendarData: vm.calendarMonthAttendanceDetail,
                      ),

                      SizedBox(height: 20),

                      // 1 Month Summary Table
                 _SummaryTable(
  title: "1 month summary",
  summaryData: (vm.student1MonthSummary != null && vm.student1MonthSummary.isNotEmpty)
      ? vm.student1MonthSummary
      : [
          {
            'attendanceCode': '\\', // double-backslash in Dart to show single "\"
            'count': 0,
          }
        ],
),

                      SizedBox(height: 18),

                      // 3 Month Summary Table
                      if (vm.student3MonthSummary != null && vm.student3MonthSummary.isNotEmpty)
                        _SummaryTable(
                          title: "3 month summary",
                          summaryData: vm.student3MonthSummary,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Pills for school/year/period
  Widget _pill(String text) => Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF5D99F6),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      );
}

// --- Calendar Widget ---
class _CustomCalendar extends StatelessWidget {
  final List<dynamic>? calendarData;
  const _CustomCalendar({Key? key, required this.calendarData}) : super(key: key);

  int weekdayToColIndex(int weekday) {
    switch (weekday) {
      case DateTime.sunday: return 0;
      case DateTime.monday: return 1;
      case DateTime.tuesday: return 2;
      case DateTime.wednesday: return 3;
      case DateTime.friday: return 4;
      case DateTime.saturday: return 5;
      default: return -1; // Thursday
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    final Map<int, String?> attendance = {};
    if (calendarData != null) {
      for (var entry in calendarData!) {
        if (entry['calendarDay'] != null) {
          attendance[entry['calendarDay']] = entry['attendanceCode'];
        }
      }
    }

    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Fri', 'Sat'];
    List<TableRow> rows = [
      TableRow(
        children: List.generate(6, (i) => _calendarBox(null, label: days[i], isHeader: true, height: 32)),
      ),
    ];

    int day = 1;
    List<Widget> week = List.filled(6, _calendarBox(null), growable: false);
    int startCol = weekdayToColIndex(DateTime(year, month, 1).weekday);
    for (int i = 0; i < startCol; i++) {
      week[i] = _calendarBox(null);
    }

    while (day <= daysInMonth) {
      int col = weekdayToColIndex(DateTime(year, month, day).weekday);
      if (col == -1) { day++; continue; }
      week[col] = _calendarBox(
        day,
        isMarked: attendance[day] != null && attendance[day]!.isNotEmpty,
        height: 60,
      );
      if (col == 5 || day == daysInMonth) {
        rows.add(TableRow(children: List.from(week)));
        week = List.filled(6, _calendarBox(null), growable: false);
      }
      day++;
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: rows,
    );
  }

  // Add `height` parameter (default 42 for dates, set 32 for header)
  Widget _calendarBox(int? day, {bool isMarked = false, String? label, bool isHeader = false, double height = 60}) {
    return Container(
      margin: EdgeInsets.all(2),
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        color: isHeader
            ? Colors.white.withOpacity(0.13)
            : day == null
                ? Colors.transparent
                : (isMarked ? Color(0xFF5D99F6) : Colors.white.withOpacity(0.07)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: isHeader
            ? Text(
                label ?? "",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              )
            : day == null
                ? SizedBox.shrink()
                : Text(
                    '$day',
                    style: TextStyle(
                      color: isMarked ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
      ),
    );
  }
}
// --- Attendance Summary Table Widget ---
class _SummaryTable extends StatelessWidget {
  final String title;
  final List<dynamic> summaryData;

  const _SummaryTable({
    required this.title,
    required this.summaryData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Map summary for display
    final codeCounts = <String, int>{};
    int total = 0;
    for (final entry in summaryData) {
      final code = entry['attendanceCode'] ?? "\\";
      final count = (entry['statusCount'] as int?) ?? 0;
      if (codeCounts.containsKey(code)) {
        codeCounts[code] = codeCounts[code]! + count;
      } else {
        codeCounts[code] = count;
      }
      total += count;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white30, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          SizedBox(height: 7),
          Table(
            border: TableBorder.all(color: Colors.white30, width: 1),
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text("Attendance Code", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text("Count", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              ...codeCounts.entries.map((entry) => TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(entry.key, style: TextStyle(color: Colors.white)),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Text(entry.value.toString(), style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )),
              // Total row
              TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text("Total possible", style: TextStyle(color: Colors.white)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: Text("$total", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}


//Using for passing markCodeName 

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../viewmodels/student_attendance_summary_viewmodel.dart';

// class StudentAttendanceSummaryScreen extends StatelessWidget {
//   final String token;
//   final int studentId;
//   final String attendanceTakenDate;
//   final String selectedYearGroupName;
//   final String selectedPeriod;
//   final String tuitionCentreName;
//   final String? markCodeName;

//   const StudentAttendanceSummaryScreen({
//     required this.token,
//     required this.studentId,
//     required this.attendanceTakenDate,
//     required this.selectedYearGroupName,
//     required this.selectedPeriod,
//     required this.tuitionCentreName,
//     this.markCodeName,
//     Key? key,
//   }) : super(key: key);

//   // Utility for getting the current month/year from attendanceTakenDate (yyyy-MM-dd)
//   String getMonthYear(String attendanceTakenDate) {
//     try {
//       final date = DateTime.parse(attendanceTakenDate);
//       return "${_monthName(date.month)} ${date.year}";
//     } catch (_) {
//       return attendanceTakenDate;
//     }
//   }

//   static String _monthName(int month) {
//     const months = [
//       '', 'January', 'February', 'March', 'April', 'May', 'June',
//       'July', 'August', 'September', 'October', 'November', 'December'
//     ];
//     return months[month];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => StudentAttendanceSummaryViewModel()
//         ..fetchSummary(token, studentId, attendanceTakenDate),
//       child: Consumer<StudentAttendanceSummaryViewModel>(
//         builder: (context, vm, _) {
//           if (vm.isLoading) {
//             return Scaffold(
//               backgroundColor: Color(0xFF0B1E3A),
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           if (vm.error != null) {
//             return Scaffold(
//               backgroundColor: Color(0xFF0B1E3A),
//               body: Center(child: Text(vm.error!, style: TextStyle(color: Colors.white))),
//             );
//           }
//           if (vm.summary == null) {
//             return Scaffold(
//               backgroundColor: Color(0xFF0B1E3A),
//               body: Center(child: Text("No data found.", style: TextStyle(color: Colors.white))),
//             );
//           }

//           final student = vm.summary!;
//           final month = getMonthYear(attendanceTakenDate);

//           return Scaffold(
//             backgroundColor: Color(0xFF0B1E3A),
//             body: SafeArea(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Logo + Back
//                       Row(
//                         children: [
//                           Image.asset('assets/logo.png', width: 80, height: 80),
//                           Spacer(),
//                           TextButton.icon(
//                             onPressed: () => Navigator.pop(context),
//                             style: TextButton.styleFrom(
//                               backgroundColor: Colors.transparent,
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
//                               padding: EdgeInsets.symmetric(horizontal: 6, vertical: 7),
//                             ),
//                             icon: Icon(Icons.arrow_back, color: Colors.blueAccent, size: 22),
//                             label: Text(
//                               "Back",
//                               style: TextStyle(
//                                 color: Colors.blueAccent,
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),

//                       // Profile avatar and name
//                       Center(
//                         child: CircleAvatar(
//                           radius: 42,
//                           backgroundColor: Colors.blueGrey[600],
//                           backgroundImage: student.photoUrl != null && student.photoUrl!.isNotEmpty
//                               ? NetworkImage("https://attendanceapiuat.massivedanamik.com/resources/${student.photoUrl}")
//                               : null,
//                           child: (student.photoUrl == null || student.photoUrl!.isEmpty)
//                               ? Icon(Icons.person, size: 44, color: Colors.white)
//                               : null,
//                         ),
//                       ),
//                       SizedBox(height: 14),

//                       Center(
//                         child: Text(
//                           "${student.firstName} ${student.lastName}",
//                           style: TextStyle(
//                             fontSize: 26,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),

//                       SizedBox(height: 14),

//                       // Pills: School, Year, Period (all scrollable)
//                       SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             _pill(tuitionCentreName),
//                             SizedBox(width: 10),
//                             _pill(selectedYearGroupName),
//                             SizedBox(width: 10),
//                             _pill(selectedPeriod),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: 18),

//                       // Info card
//                       Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           borderRadius: BorderRadius.circular(18),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                              "Student Address:  ${student.addressLine1 ?? '-'}",
//                               style: TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "Parents number: ${student.phone ?? '-'}",
//                               style: TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                             SizedBox(height: 8),
//                             Text(
//                               "Additional notes: N/A", // Make dynamic if you have notes
//                               style: TextStyle(color: Colors.white, fontSize: 16),
//                             ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: 18),

//                       // Calendar Section
//                       Text(
//                         month,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 4),
//                       _CustomCalendar(
//                         calendarData: vm.calendarMonthAttendanceDetail,
//                       ),

//                       SizedBox(height: 20),

//                       // 1 Month Summary Table
//                       SummaryTable(
//                         title: "1 month summary",
//                         summaryData: (vm.student1MonthSummary != null && vm.student1MonthSummary.isNotEmpty)
//                             ? vm.student1MonthSummary
//                             : [
//                                 {'attendanceCode': '\\', 'count': 0},
//                               ],
//                       ),

//                       SizedBox(height: 18),

//                       // 3 Month Summary Table
//                       if (vm.student3MonthSummary != null && vm.student3MonthSummary.isNotEmpty)
//                         SummaryTable(
//                           title: "3 month summary",
//                           summaryData: vm.student3MonthSummary,
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Pills for school/year/period
//   Widget _pill(String text) => Container(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//         decoration: BoxDecoration(
//           color: Color(0xFF5D99F6),
//           borderRadius: BorderRadius.circular(22),
//         ),
//         child: Text(
//           text,
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
//         ),
//       );
// }

// // --- Calendar Widget (TOP LEVEL) ---
// class _CustomCalendar extends StatelessWidget {
//   final List<dynamic>? calendarData;
//   const _CustomCalendar({Key? key, required this.calendarData}) : super(key: key);

//   int weekdayToColIndex(int weekday) {
//     switch (weekday) {
//       case DateTime.sunday:
//         return 0;
//       case DateTime.monday:
//         return 1;
//       case DateTime.tuesday:
//         return 2;
//       case DateTime.wednesday:
//         return 3;
//       case DateTime.friday:
//         return 4;
//       case DateTime.saturday:
//         return 5;
//       default:
//         return -1; // Thursday
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final now = DateTime.now();
//     final year = now.year;
//     final month = now.month;
//     final daysInMonth = DateUtils.getDaysInMonth(year, month);

//     final Map<int, String?> attendanceSymbol = {};
//     if (calendarData != null) {
//       for (var entry in calendarData!) {
//         if (entry['calendarDay'] != null) {
//           attendanceSymbol[entry['calendarDay']] =
//               entry['attendanceCodeName'] ?? entry['attendanceCode'] ?? '';
//         }
//       }
//     }

//     final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Fri', 'Sat'];
//     List<TableRow> rows = [
//       TableRow(
//         children: List.generate(
//           6,
//           (i) => _calendarBox(null, label: days[i], isHeader: true, height: 38), // header row height
//         ),
//       ),
//     ];

//     int day = 1;
//     List<Widget> week = List.filled(6, _calendarBox(null), growable: false);
//     int startCol = weekdayToColIndex(DateTime(year, month, 1).weekday);
//     for (int i = 0; i < startCol; i++) {
//       week[i] = _calendarBox(null);
//     }

//     while (day <= daysInMonth) {
//       int col = weekdayToColIndex(DateTime(year, month, day).weekday);
//       if (col == -1) {
//         day++;
//         continue;
//       }
//       week[col] = _calendarBox(
//         day,
//         isMarked: attendanceSymbol[day] != null && attendanceSymbol[day]!.isNotEmpty,
//         symbol: attendanceSymbol[day],
//         height: 60, // <-- Increased cell height here!
//       );
//       if (col == 5 || day == daysInMonth) {
//         rows.add(TableRow(children: List.from(week)));
//         week = List.filled(6, _calendarBox(null), growable: false);
//       }
//       day++;
//     }

//     return Table(
//       defaultVerticalAlignment: TableCellVerticalAlignment.middle,
//       children: rows,
//     );
//   }

//   Widget _calendarBox(
//     int? day, {
//     bool isMarked = false,
//     String? symbol,
//     String? label,
//     bool isHeader = false,
//     double height = 60, // <-- Default cell height increased here!
//   }) {
//     return Container(
//       margin: EdgeInsets.all(2),
//       height: height,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.white24),
//         color: isHeader
//             ? Colors.white.withOpacity(0.13)
//             : day == null
//                 ? Colors.transparent
//                 : (isMarked ? Color(0xFF5D99F6) : Colors.white.withOpacity(0.07)),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Center(
//         child: isHeader
//             ? Text(
//                 label ?? "",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                   letterSpacing: 1,
//                 ),
//               )
//             : day == null
//                 ? SizedBox.shrink()
//                 : isMarked && symbol != null
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             '$day',
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 2),
//                           Text(
//                             symbol,
//                             style: TextStyle(
//                               color: Colors.black,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       )
//                     : Text(
//                         '$day',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//       ),
//     );
//   }
// }

// // --- Attendance Summary Table Widget (TOP LEVEL) ---
// class SummaryTable extends StatelessWidget {
//   final String title;
//   final List<dynamic> summaryData;

//   const SummaryTable({
//     required this.title,
//     required this.summaryData,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final codeCounts = <String, int>{};
//     int total = 0;
//     for (final entry in summaryData) {
//       final code = entry['attendanceCode'] ?? "\\";
//       final count = (entry['statusCount'] as int?) ?? 0;
//       if (codeCounts.containsKey(code)) {
//         codeCounts[code] = codeCounts[code]! + count;
//       } else {
//         codeCounts[code] = count;
//       }
//       total += count;
//     }

//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.symmetric(vertical: 6),
//       padding: EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.white30, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15)),
//           SizedBox(height: 7),
//           Table(
//             border: TableBorder.all(color: Colors.white30, width: 1),
//             children: [
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(6),
//                     child: Text("Attendance Code",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold)),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(6),
//                     child: Text("Count",
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//               ...codeCounts.entries.map((entry) => TableRow(
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.all(6),
//                         child: Text(entry.key,
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                       Padding(
//                         padding: EdgeInsets.all(6),
//                         child: Text(entry.value.toString(),
//                             style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   )),
//               // Total row
//               TableRow(
//                 children: [
//                   Padding(
//                     padding: EdgeInsets.all(6),
//                     child: Text("Total possible",
//                         style: TextStyle(color: Colors.white)),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(6),
//                     child:
//                         Text("$total", style: TextStyle(color: Colors.white)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
