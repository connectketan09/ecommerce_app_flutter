class User {
  final int id;
  final String email;
  final String password;
  final String name;
  final String role;
  final String avatar;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      role: json['role'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': role,
      'avatar': avatar,
    };
  }
}
