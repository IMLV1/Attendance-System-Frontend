class RoleManagementModel {
  final List<RoleSystem> mainRole;
  final List<RoleSystem> specialRole;

  RoleManagementModel({
    required this.mainRole,
    required this.specialRole,
  });

  factory RoleManagementModel.fromJson(Map<String, dynamic> json) {
    return RoleManagementModel(
      mainRole: (json['mainRole'] as List? ?? []).map((e) => RoleSystem.fromJson(e)).toList(),
      specialRole: (json['specialRole'] as List? ?? []).map((e) => RoleSystem.fromJson(e)).toList(),
    );
  }
}

class RoleSystem {
  final String roleName;
  final String? roleColor;
  final List<Member> members;

  RoleSystem({
    required this.roleName,
    this.roleColor,
    required this.members,
  });

  factory RoleSystem.fromJson(Map<String, dynamic> json) {
    return RoleSystem(
      roleName: json['roleName'] ?? '',
      roleColor: json['roleColor'] ?? '',
      members: (json['members'] as List? ?? []).map((e) => Member.fromJson(e)).toList(),
    );
  }
}

class Member {
  final String thName;
  final String enName;
  final String avatarUrl;

  Member({
    required this.thName,
    required this.enName,
    required this.avatarUrl,
  });


  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      thName: json['thName'] ?? '',
      enName: json['enName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}
