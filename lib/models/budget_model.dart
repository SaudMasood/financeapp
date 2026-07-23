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
      // SQLite REAL columns can come back as int when the stored value
      // has no fractional part (e.g. 5000 instead of 5000.0). Assigning
      // that directly to a `double` field throws:
      // "type 'int' is not a subtype of type 'double'".
      // (map['limitAmount'] as num).toDouble() handles both cases safely.
      limitAmount: (map['limitAmount'] as num).toDouble(),
      month: map['month'],
    );
  }
}