class StudentAttendanceSummaryModel {
  final int studentId;
  final String firstName;
  final String lastName;
  final String? postalCode;
  final String? photoUrl;
  final String? addressLine1;
  final String? email;
  final String? phone;

  StudentAttendanceSummaryModel({
    required this.studentId,
    required this.firstName,
    required this.lastName,
    this.postalCode,
    this.photoUrl,
    this.addressLine1,
    this.email,
    this.phone,
  });

  factory StudentAttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummaryModel(
      studentId: json['studentId'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      postalCode: json['postalcode'],
      photoUrl: json['photoURL'],
      addressLine1: json['addressLine1'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
