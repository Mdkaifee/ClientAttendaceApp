class UserModel {
  final String accessToken;
  final String educationCentreName;
  // Add other fields as needed

  UserModel({
    required this.accessToken,
    required this.educationCentreName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['accessToken'] ?? '',
      educationCentreName: json['user'] != null && json['user']['educationCentreName'] != null
          ? json['user']['educationCentreName']
          : '',
    );
  }
}
