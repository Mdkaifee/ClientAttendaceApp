class AttendanceModel {
  final String studentName;
  final int studentId;
  final String avatarUrl;
  String lateMinutes; // to hold user input
  String? markCodeId; // optional: to track selected mark code
  String? markSubCodeId; // optional: to track sub-mark code
  String? markSubCodeDescription; // New field for description of selected subcode
  final String token; // Add this to hold token for API requests
  final int classId; // Add this for class ID
  final int calendarModelId; // Add this for calendar model ID
  final String
  educationCentreClassIdDesc; // Add this for education class description
  bool isMarked;
  String? markCodeName;

  AttendanceModel({
    required this.studentName,
    required this.studentId,
    required this.avatarUrl,
    this.lateMinutes = "0", // default to "0"
    this.markCodeId,
    this.markSubCodeId,
    this.markSubCodeDescription, // Initialize the description
    required this.token, // Initialize the token
    required this.classId, // Initialize the classId
    required this.calendarModelId, // Initialize the calendarModelId
    required this.educationCentreClassIdDesc, // Initialize the education class description
    this.isMarked = false,
    this.markCodeName,
  });

  // From JSON response to create an AttendanceModel object
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      studentName: "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}"
          .trim(),
      studentId: json['studentId'],
      avatarUrl: json['photoURL'] ?? "",
      lateMinutes: "0",
      // Default value
      markCodeId: null,
      // Default value
      markSubCodeId: null,
      // Default value
      markSubCodeDescription: null,
      // Default value for description
      token: json['token'] ?? '',
      // Set token if available
      classId: json['classId'] ?? 0,
      // Set classId if available
      calendarModelId: json['calendarModelId'] ?? 0,
      // Set calendarModelId if available
      educationCentreClassIdDesc:
          json['educationCentreClassIdDesc'] ??
          'Dynamics 11 Plus Tuition Centre', // Default value if not provided
    );
  }
}
