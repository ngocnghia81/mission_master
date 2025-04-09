class Category {
  final int? id;
  final String name;
  final String description;

  Category({this.id, required this.name, required this.description});

  Map<String, dynamic> toMap() {
    return {if (id != null) 'id': id, 'name': name, 'description': description};
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }
}
