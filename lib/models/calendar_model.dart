class CalendarModel {
  final int id;
  final String name;
  final String description;

  CalendarModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}
