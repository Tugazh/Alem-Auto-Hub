class ExpenseModel {
  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime occurredAt;
  final String description;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.occurredAt,
    required this.description,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) => ExpenseModel(
    id: json['id']?.toString() ?? '',
    title: json['title']?.toString() ?? '',
    category: json['category']?.toString() ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    occurredAt:
        DateTime.tryParse(json['occurredAt']?.toString() ?? '') ??
        DateTime.now(),
    description: json['description']?.toString() ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'amount': amount,
    'occurredAt': occurredAt.toIso8601String(),
    'description': description,
  };
}
