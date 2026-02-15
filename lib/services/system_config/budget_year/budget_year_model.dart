class BudgetYearModel {
  final int day;
  final int month;

  BudgetYearModel({
    required this.day,
    required this.month,
  });

  factory BudgetYearModel.fromJson(Map<String, dynamic> json) {
    return BudgetYearModel(
      day: json['day'] ?? 1,
      month: json['month'] ?? 1,
    );
  }
}
