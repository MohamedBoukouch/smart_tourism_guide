import '../enums/user_role.dart';

class User {
  final String email;
  final String username;
  final String password;
  final UserRole role;

  User({
    required this.email,
    required this.username,
    required this.password,
    required this.role,
  });

  /// DTO / JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
      'role': role.name,
    };
  }

  /// Factory (like Java constructor from DTO)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      username: json['username'],
      password: json['password'],
      role: UserRole.values.byName(json['role']),
    );
  }
}