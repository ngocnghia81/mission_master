class User {
  final int? id;
  final String name;
  final String email;
  final int age;

  User({this.id, required this.name, required this.email, required this.age});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email, 'age': age};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      age: map['age'],
    );
  }
}
