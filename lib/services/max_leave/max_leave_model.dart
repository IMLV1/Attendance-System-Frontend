

class MaxLeaveModel {
  final double sick;
  final double personal;
  final double vacation;
  final double maternity;
  final double paternity;
  final double parental;

  MaxLeaveModel({
    required this.sick,
    required this.personal,
    required this.vacation,
    required this.maternity,
    required this.paternity,
    required this.parental,
  });

  factory MaxLeaveModel.fromJson(Map<String, dynamic> json) {
    return MaxLeaveModel(
      sick: (json['sick'] ?? 0 as num).toDouble(),
      personal: (json['personal'] ?? 0 as num).toDouble(),
      vacation: (json['vacation'] ?? 0 as num).toDouble(),
      maternity: (json['maternity'] ?? 0 as num).toDouble(),
      paternity: (json['paternity'] ?? 0 as num).toDouble(),
      parental: (json['parental'] ?? 0 as num).toDouble(),
    );
  }

  MaxLeaveModel copyWith({
    double? sick,
    double? personal,
    double? vacation,
    double? maternity,
    double? paternity,
    double? parental,
  }) {
    return MaxLeaveModel(
      sick: sick ?? this.sick,
      personal: personal ?? this.personal,
      vacation: vacation ?? this.vacation,
      maternity: maternity ?? this.maternity,
      paternity: paternity ?? this.paternity,
      parental: parental ?? this.parental,
    );
  }
}
