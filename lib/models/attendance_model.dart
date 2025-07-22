class AttendanceModel {
  final String studentName;
  final int studentId;
  final String avatarUrl;
  String lateMinutes;        // add this to hold user input
  String? markCodeId;        // optional: to track selected mark code
  String? markSubCodeId;     // optional: to track sub-mark code

  AttendanceModel({
    required this.studentName,
    required this.studentId,
    required this.avatarUrl,
    this.lateMinutes = "0",   // default to "0"
    this.markCodeId,
    this.markSubCodeId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      studentName: "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}".trim(),
      studentId: json['studentId'],
      avatarUrl: json['photothumbnailURL'] ?? "",
      lateMinutes: "0",
      markCodeId: null,
      markSubCodeId: null,
    );
  }
}
