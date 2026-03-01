import 'package:attendance_system/services/user_management/user_management_model.dart';

class PersonnelInfoModel {
  final String id;
  final String nameTH;
  final String nameEN;
  final List<Role> roles;
  final String avatarUrl;
  final String initRole;

  const PersonnelInfoModel({
    required this.id,
    required this.nameTH,
    required this.nameEN,
    required this.roles,
    required this.avatarUrl,
    required this.initRole
  });

  factory PersonnelInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonnelInfoModel(
      id: json['id'] ?? '',
      nameTH: json['name-th'] ?? '',
      nameEN: json['name-en'] ?? '',
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e))
          .toList() ?? [],
      avatarUrl: json['avatar-url'] ?? '',
      initRole: json['initial-role'] ?? '',
    );
  }
}