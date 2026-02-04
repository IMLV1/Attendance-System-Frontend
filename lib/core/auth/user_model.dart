class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final List<String> roleType;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.roleType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['picture'],
      roleType: List<String>.from(json['role'] ?? []),
    );
  }
}
