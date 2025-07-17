import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_select_viewmodel.dart';
import 'attendance_screen.dart';

class RegisterSelectScreen extends StatelessWidget {
  final String token;
  final String tuitionCentreName;

  RegisterSelectScreen({required this.token, required this.tuitionCentreName});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterSelectViewModel()..fetchYearGroups(token),
      child: Scaffold(
        backgroundColor: Color(0xFF162244),
        body: Consumer<RegisterSelectViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (vm.error != null) {
              return Center(child: Text(vm.error!, style: TextStyle(color: Colors.white)));
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo at the top-left
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset('assets/logo.png'),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Title Text
                    Text(
                      'Register select',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Instruction Text
                    Text(
                      'Select your Year group/Class and\nPeriod in the drop-downs below and fill\nin the register on the next page.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 24),

                    // Container for Dropdown and Year group/Class and Period selection
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      height: 380, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           SizedBox(height: 16), 
                          // Tuition Centre Name
                          Text(
                            tuitionCentreName,
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                          SizedBox(height: 24),

                          // Year Group/Class Dropdown
                          Text('Year Group/Class *', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            dropdownColor: Color(0xFF0B1C49),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFF0B1C49),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: Colors.blueAccent),
                              ),
                            ),
                            value: vm.selectedYearGroupId,
                            items: [
                              DropdownMenuItem(
                                value: null, // Represents 'Select' option
                                child: Text('Select Year Group', style: TextStyle(color: Colors.white)),
                              ),
                              ...vm.yearGroups.map(
                                (e) => DropdownMenuItem(
                                  value: e.id,
                                  child: Text(e.name, style: TextStyle(color: Colors.white)),
                                ),
                              ).toList(),
                            ],
                            onChanged: (val) {
                              vm.selectedYearGroupId = val;
                              vm.notifyListeners();
                            },
                          ),

                          SizedBox(height: 24),

                          // Period Dropdown
                          Text('Period *', style: TextStyle(color: Colors.white70)),
                          SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            dropdownColor: Color(0xFF0B1C49),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFF0B1C49),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(color: Colors.blueAccent),
                              ),
                            ),
                            value: vm.selectedPeriod,
                            items: [
                              DropdownMenuItem(
                                value: null, // Represents 'Select' option
                                child: Text('Select Period', style: TextStyle(color: Colors.white)),
                              ),
                              ...['SUN_PERIOD1', 'SUN_PERIOD2', 'MON_PERIOD1', 'MON_PERIOD2']
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e, style: TextStyle(color: Colors.white)),
                                    ),
                                  )
                                  .toList(),
                            ],
                            onChanged: (val) {
                              vm.selectedPeriod = val;
                              vm.notifyListeners();
                            },
                          ),
                        ],
                      ),
                    ),
                    Spacer(),

                    // Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: (vm.selectedYearGroupId != null && vm.selectedPeriod != null)
                            ? () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AttendanceScreen(
                                      token: token,
                                      classId: vm.selectedYearGroupId!,
                                      attendanceTakenDate: DateTime.now().toIso8601String().split('T')[0],
                                      calendarModelId: 1239,
                                      tuitionCentreName: tuitionCentreName,
                                      selectedYearGroupName: vm.yearGroups
                                          .firstWhere((e) => e.id == vm.selectedYearGroupId!)
                                          .name,
                                      selectedPeriod: vm.selectedPeriod!,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
