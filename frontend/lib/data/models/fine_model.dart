class FineModel {
  final String id;
  final String title;
  final String description;
  final String status; // unpaid, paid
  final double amount;
  final DateTime issuedAt;
  final String location;
  final String? photoUrl;

  const FineModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.amount,
    required this.issuedAt,
    required this.location,
    this.photoUrl,
  });

  factory FineModel.fromJson(Map<String, dynamic> json) {
    return FineModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unpaid',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      issuedAt:
          DateTime.tryParse(json['issuedAt']?.toString() ?? '') ??
          DateTime.now(),
      location: json['location']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'amount': amount,
    'issuedAt': issuedAt.toIso8601String(),
    'location': location,
    'photoUrl': photoUrl,
  };
}
