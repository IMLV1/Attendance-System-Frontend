// ================= ENUM =================
enum RoleType { mainRole, specialRole, hr, admin, }

// ================= UTILS =================
RoleType roleTypeFromJson(String? value) {
  switch (value) {
    case 'admin':
      return RoleType.admin;
    case 'hr':
      return RoleType.hr;
    case 'special':
      return RoleType.specialRole;
    case 'main':
    default:
      return RoleType.mainRole;
  }
}

String roleTypeToApi(RoleType type) {
  switch (type) {
    case RoleType.admin:
      return 'admin';
    case RoleType.hr:
      return 'hr';
    case RoleType.specialRole:
      return 'specialRole';
    case RoleType.mainRole:
    default:
      return 'mainRole';
  }
}

bool isMainGroup(RoleType type) {
  return type == RoleType.mainRole ||
      type == RoleType.hr ||
      type == RoleType.admin;
}

String roleTypeToText(RoleType type) {
  return isMainGroup(type) ? 'ตำแหน่งหลัก' : 'ตำแหน่งเพิ่มเติม';
}

// ================= MODEL =================
class RoleManagementModel {
  final List<RoleSystem> mainRole;
  final List<RoleSystem> specialRole;

  RoleManagementModel({
    required this.mainRole,
    required this.specialRole,
  });

  factory RoleManagementModel.fromJson(Map<String, dynamic> json) {
    final List rawMain =
    (json['mainRoles'] ?? json['mainRole'] ?? []) as List;
    final List rawSpecial =
    (json['specialRoles'] ?? json['specialRole'] ?? []) as List;

    final roles = [
      ...rawMain.map((e) => RoleSystem.fromJson(e)),
      ...rawSpecial.map((e) => RoleSystem.fromJson(e)),
    ];

    return RoleManagementModel(
      mainRole: roles
          .where((r) =>
      r.type == RoleType.mainRole ||
          r.type == RoleType.hr ||
          r.type == RoleType.admin)
          .toList(),
      specialRole:
      roles.where((r) => r.type == RoleType.specialRole).toList(),
    );
  }
}

// ================= ROLE =================
class RoleSystem {
  final String id;
  final String roleName;
  final String? roleColor;
  final List<Member> members;
  final RoleType type;

  RoleSystem({
    required this.id,
    required this.roleName,
    this.roleColor,
    required this.members,
    required this.type,
  });

  RoleSystem copyWith({
    String? roleName,
    String? roleColor,
    List<Member>? members,
    RoleType? type,
  }) {
    return RoleSystem(
      id: id,
      roleName: roleName ?? this.roleName,
      roleColor: roleColor ?? this.roleColor,
      members: members ?? this.members,
      type: type ?? this.type,
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
      type: roleTypeFromJson(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roleName': roleName,
      'roleColor': roleColor,
      'type': roleTypeToApi(type),
    };
  }
}

// ================= MEMBER =================
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
