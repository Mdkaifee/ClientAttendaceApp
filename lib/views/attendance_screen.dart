// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../viewmodels/attendance_viewmodel.dart';

// class AttendanceScreen extends StatelessWidget {
//   final String token; // pass token via navigation

//   AttendanceScreen({required this.token});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => AttendanceViewModel()
//   ..loadAttendance(
//     token: token,
//     classId: 1021, // or your dynamic class id
//     attendanceTakenDate: "2024-12-14", // or a chosen date
//     calendarModelId: 1239, // or your dynamic calendar id
//   ),

//       child: Consumer<AttendanceViewModel>(
//         builder: (context, vm, _) {
//           if (vm.isLoading) {
//             return Scaffold(body: Center(child: CircularProgressIndicator()));
//           }
//           if (vm.error != null) {
//             return Scaffold(body: Center(child: Text(vm.error!)));
//           }
//           return Scaffold(
//             backgroundColor: Color(0xFF162244),
//             appBar: AppBar(
//               title: Text('Attendance', style: TextStyle(color: Colors.white)),
//               backgroundColor: Colors.transparent,
//               elevation: 0,
//               iconTheme: IconThemeData(color: Colors.white),
//             ),
//             body: Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   child: Row(
//                     children: [
//                       Expanded(child: TextField(decoration: InputDecoration(hintText: 'Search', filled: true, fillColor: Colors.white12))),
//                       SizedBox(width: 10),
//                       DropdownButton<String>(
//                         value: 'Sort',
//                         items: ['Sort'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
//                         onChanged: (_) {},
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Class tabs and period can go here
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: vm.students.length,
//                     itemBuilder: (context, index) {
//                       final student = vm.students[index];
//                       return Card(
//                         color: Colors.white10,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                         margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         child: ListTile(
//                           leading: CircleAvatar(
//                             backgroundImage: student.avatarUrl.isNotEmpty
//                                 ? NetworkImage(student.avatarUrl)
//                                 : null,
//                             child: student.avatarUrl.isEmpty
//                                 ? Icon(Icons.person, color: Colors.white70)
//                                 : null,
//                           ),
//                           title: Text(student.studentName, style: TextStyle(color: Colors.white)),
//                           trailing: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               TextButton(onPressed: () {}, child: Text('Mark', style: TextStyle(color: Colors.white))),
//                               TextButton(onPressed: () {}, child: Text('Mark', style: TextStyle(color: Colors.white))),
//                               SizedBox(width: 40, child: TextField(decoration: InputDecoration(hintText: 'Late', hintStyle: TextStyle(color: Colors.white38), fillColor: Colors.white12, filled: true))),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {},
//                       style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: EdgeInsets.symmetric(vertical: 16)),
//                       child: Text("Submit", style: TextStyle(fontSize: 18)),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/attendance_viewmodel.dart';

class AttendanceScreen extends StatelessWidget {
  final String token; // pass token via navigation

  AttendanceScreen({required this.token});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AttendanceViewModel()
        ..loadAttendance(
          token: token,
          classId: 1021,
          attendanceTakenDate: "2024-12-14",
          calendarModelId: 1239,
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

          return Scaffold(
            backgroundColor: Color(0xFF0B1E3A), // Dark blue background
          appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          title: Row(
            children: [
              Image.asset(
                'assets/logo.png', // Make sure your logo image is placed here
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
                            value: 'Sort',
                            dropdownColor: Color(0xFF16345E),
                            iconEnabledColor: Colors.white,
                            items: ['Sort']
                                .map((val) => DropdownMenuItem(
                                      value: val,
                                      child: Text(val, style: TextStyle(color: Colors.white)),
                                    ))
                                .toList(),
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Tabs for Year and Period
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF1F4F91),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text('Year 7', style: TextStyle(color: Colors.white)),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF1F4F91),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: Text('SUN_PERIOD1', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Header row
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

                  // List of students
                  Expanded(
                    child: ListView.builder(
                      itemCount: vm.students.length,
                      itemBuilder: (context, index) {
                        final student = vm.students[index];
                        return Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              // Avatar + Name
                              Expanded(
                                flex: 4,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey.shade800,
                                      backgroundImage: student.avatarUrl.isNotEmpty
                                          ? NetworkImage(student.avatarUrl)
                                          : null,
                                      child: student.avatarUrl.isEmpty
                                          ? Icon(Icons.person, color: Colors.white54, size: 24)
                                          : null,
                                    ),
                                    SizedBox(width: 12),
                                    Flexible(
                                      child: Text(
                                        student.studentName,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500,fontSize:10),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Mark button
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1F4F91),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      elevation: 0,
                                    ),
                                    child: Text('Mark', style: TextStyle(color: Colors.white,fontSize:12)),
                                  ),
                                ),
                              ),

                              // Sub-Mark button
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF1F4F91),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      elevation: 0,
                                    ),
                                    child: Text('Mark', style: TextStyle(color: Colors.white,fontSize:12)),
                                  ),
                                ),
                              ),

                              // Late input box
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

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1F4F91),
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
