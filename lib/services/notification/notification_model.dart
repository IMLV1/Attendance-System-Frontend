class NotificationModel {
  final String id;
  final String title;
  final String message;
  final bool isRead;
  final String type; // e.g., 'LEAVE_REQUEST', 'ATTENDANCE_REQUEST'
  final String status; // e.g., 'APPROVED', 'REJECTED', 'PENDING'
  final String requestNumber; // e.g., 'LEV00000000065012'
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.type,
    required this.status,
    required this.requestNumber,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String,
      status: json['status'] as String? ?? 'PENDING',
      requestNumber: json['requestNumber'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'isRead': isRead,
      'type': type,
      'status': status,
      'requestNumber': requestNumber,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Helper method to copy with changed fields
  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    bool? isRead,
    String? type,
    String? status,
    String? requestNumber,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      status: status ?? this.status,
      requestNumber: requestNumber ?? this.requestNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
