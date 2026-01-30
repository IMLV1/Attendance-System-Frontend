class ProfileModel {
  final String staffId;
  final String citizenId;
  final String thName;
  final String enName;
  final String gender;
  final String nationality;
  final String phone;
  final String email;
  final String role_init;
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
    required this.role_init,
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
      role_init: json['role_init'] ?? '',
      avatarUrl: json['picture'] ?? '',
    );
  }
}
