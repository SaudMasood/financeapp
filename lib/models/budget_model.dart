class BudgetModel {
  int? id;
  String category;
  double limitAmount;
  String month; // stored as yyyy-MM

  BudgetModel({
    this.id,
    required this.category,
    required this.limitAmount,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limitAmount': limitAmount,
      'month': month,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limitAmount: map['limitAmount'],
      month: map['month'],
    );
  }
}
