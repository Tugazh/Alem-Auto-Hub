class BookingModel {
  final String id;
  final String serviceName;
  final String address;
  final DateTime date;
  final String timeSlot;
  final String status; // upcoming, completed, cancelled
  final double price;

  const BookingModel({
    required this.id,
    required this.serviceName,
    required this.address,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.price,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
    id: json['id']?.toString() ?? '',
    serviceName: json['serviceName']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    timeSlot: json['timeSlot']?.toString() ?? '',
    status: json['status']?.toString() ?? 'upcoming',
    price: (json['price'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceName': serviceName,
    'address': address,
    'date': date.toIso8601String(),
    'timeSlot': timeSlot,
    'status': status,
    'price': price,
  };
}
