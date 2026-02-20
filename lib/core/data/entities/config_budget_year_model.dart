class ConfigBudgetYearModel {
  final int day;
  final int month;

  ConfigBudgetYearModel({
    required this.day,
    required this.month,
  });

  factory ConfigBudgetYearModel.fromJson(Map<String, dynamic> json) {
    return ConfigBudgetYearModel(
      day: json['day'] ?? 1,
      month: json['month'] ?? 1,
    );
  }
}
