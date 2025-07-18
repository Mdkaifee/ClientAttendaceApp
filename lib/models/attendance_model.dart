class AttendanceModel {
  final String studentName;
  final int studentId;
  final String avatarUrl;
  final bool marked;
  final bool subMark;
  final bool late;

  AttendanceModel({
    required this.studentName,
    required this.studentId,
    required this.avatarUrl,
    this.marked = false,
    this.subMark = false,
    this.late = false,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      studentName: "${json['firstName'] ?? ''} ${json['lastName'] ?? ''}".trim(),
      studentId: json['studentId'],
      avatarUrl: json['photothumbnailURL'] ?? "", // Use thumbnail if available, else fallback to ""
      marked: false,   // Default, update according to your app logic
      subMark: false,  // Default
      late: false,     // Default
    );
  }
}
