class ProfileModel {
  final String staffId;
  final String citizenId;
  final String thName;
  final String enName;
  final String gender;
  final String nationality;
  final String phone;
  final String email;
  final List<Role> roles;
  final String avatarUrl;

  ProfileModel({
    required this.staffId,
    required this.citizenId,
    required this.thName,
    required this.enName,
    required this.gender,
    required this.nationality,
    required this.phone,
    required this.email,
    required this.roles,
    required this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      staffId: json['employee_id'] ?? '',
      citizenId: json['user_id'] ?? '',
      thName: json['fullname_thai'] ?? '',
      enName: json['fullname_eng'] ?? '',
      gender: json['gender'] ?? '',
      nationality: json['nationality'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      roles: (json['role_sys'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e))
          .toList() ?? [],
      avatarUrl: json['picture'] ?? '',
    );
  }
}

class Role {
  final String name;
  final String colorHex;

  Role({required this.name, required this.colorHex});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      name: json['role_name'] ?? '',
      colorHex: json['role_color'] ?? '#000000',
    );
  }
}