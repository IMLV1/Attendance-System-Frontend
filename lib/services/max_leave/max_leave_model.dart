

class MaxLeaveModel {
  final double sick;
  final double personal;
  final double vacation;
  final double maternity;
  final double paternity;
  final double parental;
  final double ordination;
  final double military;
  final double rehabilitation;

  MaxLeaveModel({
    required this.sick,
    required this.personal,
    required this.vacation,
    required this.maternity,
    required this.paternity,
    required this.parental,
    required this.ordination,
    required this.military,
    required this.rehabilitation,
  });

  factory MaxLeaveModel.fromJson(Map<String, dynamic> json) {
    return MaxLeaveModel(
      sick: (json['sick'] ?? 0 as num).toDouble(),
      personal: (json['personal'] ?? 0 as num).toDouble(),
      vacation: (json['vacation'] ?? 0 as num).toDouble(),
      maternity: (json['maternity'] ?? 0 as num).toDouble(),
      paternity: (json['paternity'] ?? 0 as num).toDouble(),
      parental: (json['parental'] ?? 0 as num).toDouble(),
      ordination: (json['ordination'] ?? 0 as num).toDouble(),
      military: (json['military'] ?? 0 as num).toDouble(),
      rehabilitation: (json['rehabilitation'] ?? 0 as num).toDouble(),
    );
  }

  MaxLeaveModel copyWith({
    double? sick,
    double? personal,
    double? vacation,
    double? maternity,
    double? paternity,
    double? parental,
    double? ordination,
    double? military,
    double? rehabilitation,
  }) {
    return MaxLeaveModel(
      sick: sick ?? this.sick,
      personal: personal ?? this.personal,
      vacation: vacation ?? this.vacation,
      maternity: maternity ?? this.maternity,
      paternity: paternity ?? this.paternity,
      parental: parental ?? this.parental,
      ordination: ordination ?? this.ordination,
      military: military ?? this.military,
      rehabilitation: rehabilitation ?? this.rehabilitation,
    );
  }

  @override
  String toString() {
    return {
      'sick': sick,
      'personal': personal,
      'vacation': vacation,
      'maternity': maternity,
      'paternity': paternity,
      'parental': parental,
      'ordination': ordination,
      'military': military,
      'rehabilitation': rehabilitation,
    }.toString();
  }
}
