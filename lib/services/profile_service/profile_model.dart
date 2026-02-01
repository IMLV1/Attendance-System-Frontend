class ProfileModel {
  final String staffId;
  final String citizenId;
  final String thName;
  final String enName;
  final String gender;
  final String nationality;
  final String phone;
  final String email;
  final List<String> positions;

  ProfileModel({
    required this.staffId,
    required this.citizenId,
    required this.thName,
    required this.enName,
    required this.gender,
    required this.nationality,
    required this.phone,
    required this.email,
    required this.positions,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      staffId: json['staff_id'] ?? '',
      citizenId: json['citizen_id'] ?? '',
      thName: json['th_name'] ?? '',
      enName: json['en_name'] ?? '',
      gender: json['gender'] ?? '',
      nationality: json['nationality'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      positions: List<String>.from(json['positions'] ?? []),
    );
  }
}
