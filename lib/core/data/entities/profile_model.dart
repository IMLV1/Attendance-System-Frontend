
import 'package:attendance_system/core/data/entities/user_management_model.dart';

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
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e))
          .toList() ?? [],
      avatarUrl: json['picture'] ?? '',
    );
  }
}
