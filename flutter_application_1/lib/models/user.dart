enum UserRole { admin, user }

class UserModel {
  final int? id;
  final String email;
  final String password;
  final String name;
  final UserRole role;

  const UserModel({
    this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  bool get canCreateProducts => role == UserRole.admin;

  String get roleValue => role.name;

  factory UserModel.fromMap(Map<String, Object?> map) {
    return UserModel(
      id: map['id'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
        (item) => item.name == map['role'],
        orElse: () => UserRole.user,
      ),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': roleValue,
    };
  }
}
