class UserModel {
  final int id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar'],
      role: json['role'],
    );
  }
}
