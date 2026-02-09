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
  final String id;
  final String roleName;
  final String? roleColor;
  final List<Member> members;

  RoleSystem({
    required this.id,
    required this.roleName,
    this.roleColor,
    required this.members,
  });

  RoleSystem copyWith({
    String? roleName,
    String? roleColor,
    List<Member>? members,
  }) {
    return RoleSystem(
      id: id,
      roleName: roleName ?? this.roleName,
      roleColor: roleColor ?? this.roleColor,
      members: members ?? this.members,
    );
  }


  factory RoleSystem.fromJson(Map<String, dynamic> json) {
    return RoleSystem(
      id: json['id'],
      roleName: json['roleName'] ?? '',
      roleColor: json['roleColor'],
      members: (json['members'] as List? ?? [])
          .map((e) => Member.fromJson(e))
          .toList(),
    );
  }
}

class Member {
  final String id;
  final String thName;
  final String enName;
  final String avatarUrl;

  Member({
    required this.id,
    required this.thName,
    required this.enName,
    required this.avatarUrl,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      thName: json['thName'] ?? '',
      enName: json['enName'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}

