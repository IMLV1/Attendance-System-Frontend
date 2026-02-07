import 'dart:ui';

import 'package:flutter/material.dart';

class UserManagementModel {
  final String id;
  final String employeeId;
  final String nameTH;
  final String nameEN;
  final String gender;
  final String nationality;
  final String phone;
  final String email;
  final List<Role> roles;
  final String avatarUrl;



  UserManagementModel({
    required this.id,
    required this.employeeId,
    required this.nameTH,
    required this.nameEN,
    required this.gender,
    required this.nationality,
    required this.phone,
    required this.email,
    required this.roles,
    required this.avatarUrl
  });

  factory UserManagementModel.fromJson(Map<String, dynamic> json) {
    return UserManagementModel(
      id: json['id'] ?? '',
      employeeId: json['employee-id'] ?? '',
      nameTH: json['name-th'] ?? '',
      nameEN: json['name-en'] ?? '',
      gender: json['gender'] ?? '',
      nationality: json['nationality'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      roles: (json['roles'] as List<dynamic>?)
          ?.map((e) => Role.fromJson(e))
          .toList() ?? [],
      avatarUrl: json['avatar-url'] ?? '',
    );
  }

  static List<UserManagementModel> getList(Map<String, dynamic> json) {
    return [...json['data'].map((m) => UserManagementModel.fromJson(m))];
  }

  UserManagementModel copyWith({
    String? id,
    String? employeeId,
    String? nameTH,
    String? nameEN,
    String? gender,
    String? nationality,
    String? phone,
    String? email,
    List<Role>? roles,
    String? avatarUrl,
  }) {
    return UserManagementModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      nameTH: nameTH ?? this.nameTH,
      nameEN: nameEN ?? this.nameEN,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

class Role {
  final String name;
  final Color color;

  Role({required this.name, required this.color});

  factory Role.fromJson(Map<String, dynamic> json) {

    String hex = (json['role-color'] ?? '000000').toString().toUpperCase();

    return Role(
      name: json['role-name'] ?? '',
      color: Color(int.parse('FF$hex', radix: 16)),
    );
  }
}