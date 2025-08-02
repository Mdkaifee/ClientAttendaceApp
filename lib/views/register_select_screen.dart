import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/register_select_viewmodel.dart';
import 'attendance_screen.dart';
import 'login_screen.dart'; // Import LoginScreen
import '../models/calendar_model.dart';
import '../services/network_service.dart';
import '../models/year_group_model.dart'; // Ensure this import is correct

class RegisterSelectScreen extends StatefulWidget {
  final String token;
  final String tuitionCentreName;
  final int organizationId;
  final int tuitionCentreId;
  final int educationCentreId;

  RegisterSelectScreen({
    required this.token,
    required this.tuitionCentreName,
    required this.organizationId,
    required this.tuitionCentreId,
    required this.educationCentreId,
  });

  @override
  _RegisterSelectScreenState createState() => _RegisterSelectScreenState();
}

class _RegisterSelectScreenState extends State<RegisterSelectScreen> {
  String? _connectionError;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterSelectViewModel()..fetchYearGroups(widget.token),
      child: Scaffold(
        backgroundColor: Color(0xFF162244),
        body: Consumer<RegisterSelectViewModel>(builder: (context, vm, _) {
          if (vm.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (vm.error != null) {
            // If error occurs or token expired, navigate to LoginScreen
            if (vm.error == "Failed to fetch year groups or token expired.") {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              });
            }
            return Center(
              child: Text(vm.error!, style: TextStyle(color: Colors.white)),
            );
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo and Titles
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
                  Text(
                    'Select Register',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select your Year group/Class and\nPeriod in the drop-downs below and fill\nin the register on the next page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.4),
                  ),
                  SizedBox(height: 24),

                  // Selection Box
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
                        Text(
                          '${widget.tuitionCentreName} (${widget.organizationId} - ${widget.educationCentreId})',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                        SizedBox(height: 24),

                        // Year Group
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
                          isExpanded: true, // Ensures the dropdown takes up available width
                          items: [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text('Select Year Group', style: TextStyle(color: Colors.white)),
                            ),
                            ...vm.yearGroups.map(
                              (e) => DropdownMenuItem<int>(
                                value: e.id,  // e is a YearGroupModel here
                                child: Text(
                                  e.name,  // Display year group name
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,  // Truncate long text with ellipsis
                                  maxLines: 1,  // Ensure the text doesn't wrap to the next line
                                ),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            vm.setSelectedYearGroup(val, widget.token); // Pass the token here
                          },
                        ),

                        SizedBox(height: 24),

                        // Period
                        Text('Period *', style: TextStyle(color: Colors.white70)),
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
                          value: vm.selectedPeriodId,
                          items: [
                            DropdownMenuItem<int>(
                              value: null,
                              child: Text('Select Period', style: TextStyle(color: Colors.white)),
                            ),
                            ...vm.calendarModels.map(
                              (model) => DropdownMenuItem<int>(
                                value: model.id,
                                child: Text(model.name, style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            vm.setSelectedPeriod(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  Spacer(),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (vm.selectedYearGroupId != null && vm.selectedPeriodId != null)
                          ? () async {
                              bool isConnected = await NetworkService().isConnected();
                              if (!isConnected) {
                                setState(() {
                                  _connectionError = "No Internet Connection. Please try again.";
                                });
                                return;
                              }

                              setState(() {
                                _connectionError = null;
                              });

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AttendanceScreen(
                                    token: widget.token,
                                    classId: vm.selectedYearGroupId!,
                                    attendanceTakenDate: DateTime.now().toIso8601String().split('T')[0],
                                    calendarModelId: vm.selectedPeriodId!,
                                    tuitionCentreName: widget.tuitionCentreName,
                                    selectedYearGroupName: vm.yearGroups
                                        .firstWhere((e) => e.id == vm.selectedYearGroupId!)
                                        .name,
                                    selectedPeriod: vm.calendarModels
                                        .firstWhere((c) => c.id == vm.selectedPeriodId!)
                                        .name,
                                    organizationId: widget.organizationId,
                                    tuitionCentreId: widget.tuitionCentreId,
                                    educationCentreId: widget.educationCentreId,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        'Confirm',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
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
        }),
      ),
    );
  }
}
