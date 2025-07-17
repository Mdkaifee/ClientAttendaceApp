class AttendanceModel {
  final String studentName;
  final String avatarUrl;
  final bool marked;
  final bool subMark;
  final bool late;

  AttendanceModel({
    required this.studentName,
    required this.avatarUrl,
    this.marked = false,
    this.subMark = false,
    this.late = false,
  });

  // Add fromJson/factory if your API returns a list of students.
}
