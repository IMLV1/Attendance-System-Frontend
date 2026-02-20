

class ConfigLeaveModel {
  final LeaveSetting sick;
  final LeaveSetting personal;
  final LeaveSetting vacation;
  final LeaveSetting maternity;
  final LeaveSetting paternity;
  final LeaveSetting parental;

  ConfigLeaveModel({
    required this.sick,
    required this.personal,
    required this.vacation,
    required this.maternity,
    required this.paternity,
    required this.parental,
  });

  factory ConfigLeaveModel.fromJson(Map<String, dynamic> json) {
    return ConfigLeaveModel(
      sick: LeaveSetting.fromJson(json['sick'] ?? {}),
      personal: LeaveSetting.fromJson(json['personal'] ?? {}),
      vacation: LeaveSetting.fromJson(json['vacation'] ?? {}),
      maternity: LeaveSetting.fromJson(json['maternity'] ?? {}),
      paternity: LeaveSetting.fromJson(json['paternity'] ?? {}),
      parental: LeaveSetting.fromJson(json['parental'] ?? {}),
    );
  }

  ConfigLeaveModel copyWith({
    LeaveSetting? sick,
    LeaveSetting? personal,
    LeaveSetting? vacation,
    LeaveSetting? maternity,
    LeaveSetting? paternity,
    LeaveSetting? parental,
  }) {
    return ConfigLeaveModel(
      sick: sick ?? this.sick,
      personal: personal ?? this.personal,
      vacation: vacation ?? this.vacation,
      maternity: maternity ?? this.maternity,
      paternity: paternity ?? this.paternity,
      parental: parental ?? this.parental,
    );
  }

  bool isSame(ConfigLeaveModel other) {
    return sick.isSame(other.sick) &&
      personal.isSame(other.personal) &&
      vacation.isSame(other.vacation) &&
      maternity.isSame(other.maternity) &&
      paternity.isSame(other.paternity) &&
      parental.isSame(other.parental);
  }
}

class LeaveSetting {
  final bool requestNeedSignature;
  final bool approveNeedSignature;
  final bool allowRetroactive;
  final bool specifyRemark;
  final bool requiredRemark;
  final bool evidenceFile;
  final bool requiredEvidenceFile;

  const LeaveSetting({
    required this.requestNeedSignature,
    required this.approveNeedSignature,
    required this.allowRetroactive,
    required this.specifyRemark,
    required this.requiredRemark,
    required this.evidenceFile,
    required this.requiredEvidenceFile
  });

  factory LeaveSetting.fromJson(Map<String, dynamic> json) {
    return LeaveSetting(
      requestNeedSignature: json['request-need-signature'] ?? false,
      approveNeedSignature: json['approve-need-signature'] ?? false,
      allowRetroactive: json['allow-retroactive'] ?? false,
      specifyRemark: json['specify-remark'] ?? false,
      requiredRemark: json['required-remark'] ?? false,
      evidenceFile: json['evidence-file'] ?? false,
      requiredEvidenceFile: json['required-evidence-file'] ?? false,
    );
  }

  LeaveSetting copyWith({
    bool? requestNeedSignature,
    bool? approveNeedSignature,
    bool? allowRetroactive,
    bool? specifyRemark,
    bool? requiredRemark,
    bool? evidenceFile,
    bool? requiredEvidenceFile,
  }) {
    return LeaveSetting(
      requestNeedSignature: requestNeedSignature ?? this.requestNeedSignature,
      approveNeedSignature: approveNeedSignature ?? this.approveNeedSignature,
      allowRetroactive: allowRetroactive ?? this.allowRetroactive,
      specifyRemark: specifyRemark ?? this.specifyRemark,
      requiredRemark: requiredRemark ?? this.requiredRemark,
      evidenceFile: evidenceFile ?? this.evidenceFile,
      requiredEvidenceFile: requiredEvidenceFile ?? this.requiredEvidenceFile,
    );
  }

  bool isSame(LeaveSetting other) {
    return requestNeedSignature == other.requestNeedSignature &&
        approveNeedSignature == other.approveNeedSignature &&
        allowRetroactive == other.allowRetroactive &&
        specifyRemark == other.specifyRemark &&
        requiredRemark == other.requiredRemark &&
        evidenceFile == other.evidenceFile &&
        requiredEvidenceFile == other.requiredEvidenceFile;
  }
}