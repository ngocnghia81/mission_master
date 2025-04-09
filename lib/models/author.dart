class Author {
  final int? id;
  final String name;
  final String email;
  final String country;

  Author({
    this.id,
    required this.name,
    required this.email,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'country': country,
    };
  }

  static Author fromMap(Map<String, dynamic> map) {
    return Author(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      country: map['country'] as String,
    );
  }
}
