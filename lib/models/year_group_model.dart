class YearGroupModel {
  final int id;
  final String name;

  YearGroupModel({required this.id, required this.name});

  factory YearGroupModel.fromJson(Map<String, dynamic> json) {
    return YearGroupModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
