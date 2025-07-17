class UserModel {
  final String accessToken;
  // Add other fields as needed

  UserModel({required this.accessToken});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['accessToken'] ?? '',
    );
  }
}
