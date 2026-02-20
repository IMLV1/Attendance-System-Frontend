

class ConfigAttendanceRequestModel {
  final bool requestNeedSignature;
  final bool approveNeedSignature;
  final bool specifyApprovalReason;

  final bool specifyRemark;
  final bool requiredRemark;
  final bool evidenceFile;
  final bool requiredEvidenceFile;

  ConfigAttendanceRequestModel({
    required this.requestNeedSignature,
    required this.approveNeedSignature,
    required this.specifyApprovalReason,
    required this.specifyRemark,
    required this.requiredRemark,
    required this.evidenceFile,
    required this.requiredEvidenceFile,
  });

  factory ConfigAttendanceRequestModel.fromJson(Map<String, dynamic> json) {
    return ConfigAttendanceRequestModel(
      requestNeedSignature: json['request-need-signature'] ?? false,
      approveNeedSignature: json['approve-need-signature'] ?? false,
      specifyApprovalReason: json['specify-approval-reason'] ?? false,
      specifyRemark: json['specify-remark'] ?? false,
      requiredRemark: json['required-remark'] ?? false,
      evidenceFile: json['evidence-file'] ?? false,
      requiredEvidenceFile: json['required-evidence-file'] ?? false,
    );
  }

  ConfigAttendanceRequestModel copyWith({
    bool? requestNeedSignature,
    bool? approveNeedSignature,
    bool? specifyApprovalReason,
    bool? specifyRemark,
    bool? requiredRemark,
    bool? evidenceFile,
    bool? requiredEvidenceFile,
  }) {
    return ConfigAttendanceRequestModel(
      requestNeedSignature: requestNeedSignature ?? this.requestNeedSignature,
      approveNeedSignature: approveNeedSignature ?? this.approveNeedSignature,
      specifyApprovalReason: specifyApprovalReason ?? this.specifyApprovalReason,
      specifyRemark: specifyRemark ?? this.specifyRemark,
      requiredRemark: requiredRemark ?? this.requiredRemark,
      evidenceFile: evidenceFile ?? this.evidenceFile,
      requiredEvidenceFile: requiredEvidenceFile ?? this.requiredEvidenceFile,
    );
  }

  bool isSame(ConfigAttendanceRequestModel other) {
    return requestNeedSignature == other.requestNeedSignature &&
        approveNeedSignature == other.approveNeedSignature &&
        specifyApprovalReason == other.specifyApprovalReason &&
        specifyRemark == other.specifyRemark &&
        requiredRemark == other.requiredRemark &&
        evidenceFile == other.evidenceFile &&
        requiredEvidenceFile == other.requiredEvidenceFile;
  }
}