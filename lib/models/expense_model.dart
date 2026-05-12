class ExpenseModel {
  final int id;
  final String category;
  final double amount;
  final String date;
  final String? description;

  const ExpenseModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as int,
      category: json['category'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: json['date'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'amount': amount,
        'date': date,
        'description': description,
      };
}
