class YearGroup {
  final int id;
  final String name;

  YearGroup({required this.id, required this.name});

  factory YearGroup.fromJson(Map<String, dynamic> json) {
    return YearGroup(id: json['id'], name: json['name']);
  }
}
