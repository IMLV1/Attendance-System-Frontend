import 'dart:ui';

import 'package:flutter/material.dart';

enum RoleType { main, special }

class RoleModel {
  final String id;
  final String name;
  final Color color;
  final RoleType type;
  final int member;

  RoleModel({required this.id, required this.name, required this.color, required this.type, required this.member});

  factory RoleModel.fromJson(Map<String, dynamic> json) {

    String hex = (json['color'] ?? '000000').toString().toUpperCase();

    return RoleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: Color(int.parse('FF$hex', radix: 16)),
      type: RoleType.values.byName(json['type']),
      member: json['member'] ?? 0,
    );
  }

  static List<RoleModel> getList(Map<String, dynamic> json) {
    return [...json['data'].map((m) => RoleModel.fromJson(m))];
  }

  RoleModel copyWith({
    String? id,
    String? name,
    Color? color,
    RoleType? type,
    int? member,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      type: type ?? this.type,
      member: member ?? this.member
    );
  }
}