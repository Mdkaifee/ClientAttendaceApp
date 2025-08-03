import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_attendance_summary_viewmodel.dart';
import 'login_screen.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StudentAttendanceSummaryScreen extends StatefulWidget {
  final String token;
  final int studentId;
  final String attendanceTakenDate;
  final String selectedYearGroupName;
  final String selectedPeriod;
  final String tuitionCentreName;
  final String? photoUrl;

  const StudentAttendanceSummaryScreen({
    required this.token,
    required this.studentId,
    required this.attendanceTakenDate,
    required this.selectedYearGroupName,
    required this.selectedPeriod,
    required this.tuitionCentreName,
    this.photoUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<StudentAttendanceSummaryScreen> createState() => _StudentAttendanceSummaryScreenState();
}

class _StudentAttendanceSummaryScreenState extends State<StudentAttendanceSummaryScreen> {
  ImageProvider? _studentImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    print("📸 photoUrl: ${widget.photoUrl}");
    if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
      final image = await fetchStudentImage(
        widget.studentId.toString(),
        widget.photoUrl!,
      );
      if (image != null) {
        setState(() {
          _studentImage = image;
           print("✅ Image set in state");
        });
      }
    }
  }
Future<ImageProvider?> fetchStudentImage(String studentId, String fileName) async {
  final url = Uri.parse(
    'https://adminapiuat.massivedanamik.com/api/GetStudentPhotoAsBase64StringAsync?studentId=$studentId&fileName=$fileName',
  );

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer ${widget.token}', // <-- Pass token here
      'Content-Type': 'application/json',         // Optional, but safe to include
    },
  );

  print("📡 statusCode: ${response.statusCode}");
  print("📡 body: ${response.body}");

  if (response.statusCode == 200 && response.body.isNotEmpty) {
    try {
      final base64Str = response.body.replaceAll('"', '');
      final Uint8List imageBytes = base64Decode(base64Str);
      return MemoryImage(imageBytes);
    } catch (e) {
      print("❌ Failed to decode image: $e");
    }
  }

  return null;
}
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
        ..fetchSummary(widget.token, widget.studentId, widget.attendanceTakenDate),
      child: Consumer<StudentAttendanceSummaryViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return Scaffold(
              backgroundColor: Color(0xFF0B1E3A),
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (vm.error != null) {
            if (vm.error == "Token expired or no data found,Please Login again.") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              });
            }
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
          final month = getMonthYear(widget.attendanceTakenDate);

          return Scaffold(
            backgroundColor: Color(0xFF0B1E3A),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                     Center(
  child: CircleAvatar(
    radius: 42,
    backgroundColor: Colors.blueGrey[600],
    backgroundImage: _studentImage ?? AssetImage('assets/default_avatar.png'),
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _pill(widget.tuitionCentreName),
                            SizedBox(width: 10),
                            _pill(widget.selectedPeriod),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
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
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Year Group: ",
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  TextSpan(
                                    text: widget.selectedYearGroupName,
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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
                              "Additional notes: N/A",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        month,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      _CustomCalendar(calendarData: vm.calendarMonthAttendanceDetail),
                      SizedBox(height: 20),
                      _SummaryTable(
                        title: "1 month summary",
                        summaryData: (vm.student1MonthSummary != null && vm.student1MonthSummary.isNotEmpty)
                            ? vm.student1MonthSummary
                            : [
                                {
                                  'attendanceCode': '\\',
                                  'count': 0,
                                }
                              ],
                      ),
                      SizedBox(height: 18),
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
class _CustomCalendar extends StatefulWidget {
  final List<dynamic>? calendarData;
  const _CustomCalendar({Key? key, required this.calendarData}) : super(key: key);

  @override
  State<_CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<_CustomCalendar> {
  int weekdayToColIndex(int weekday) {
    switch (weekday) {
      case DateTime.sunday: return 0;
      case DateTime.monday: return 1;
      case DateTime.tuesday: return 2;
      case DateTime.wednesday: return 3;
      case DateTime.friday: return 4;
      case DateTime.saturday: return 5;
      default: return -1; // Thursday (excluded)
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    final Map<int, String?> attendance = {};
    if (widget.calendarData != null) {
      for (var entry in widget.calendarData!) {
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
    final codeCounts = <String, int>{};
    int total = 0;
    for (final entry in summaryData) {
      final code = entry['attendanceCode'] ?? "\\";
      final count = (entry['statusCount'] as int?) ?? 0;
      codeCounts[code] = (codeCounts[code] ?? 0) + count;
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
