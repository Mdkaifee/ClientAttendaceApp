class UserModel {
  final String accessToken;
  final String educationCentreName;
  final int organizationId;
  final int tuitionCentreId;
  final int educationCentreId;
  // Add other fields as needed

  UserModel({
    required this.accessToken,
    required this.educationCentreName,
    required this.organizationId,
    required this.tuitionCentreId,
    required this.educationCentreId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['accessToken'] ?? '',
      educationCentreName: json['user'] != null && json['user']['educationCentreName'] != null
          ? json['user']['educationCentreName']
          : '',
      organizationId: json['user']?['organizationId'] ?? 0,
    tuitionCentreId: json['user']?['tuitionCentreId'] ?? json['user']?['tutionCentreId'] ?? 0,  // fix here
    educationCentreId: json['user']?['educationCentreId'] ?? 0,
    );
  }
}
