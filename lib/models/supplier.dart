import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String? receiptImageUrl;
  final DateTime date;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.receiptImageUrl,
    required this.date,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
  });

  factory Supplier.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      receiptImageUrl: data['receiptImageUrl'],
      date: (data['date'] as Timestamp).toDate(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'receiptImageUrl': receiptImageUrl,
      'date': Timestamp.fromDate(date),
      'totalAmount': totalAmount,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? receiptImageUrl,
    DateTime? date,
    double? totalAmount,
    String? notes,
    DateTime? createdAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      receiptImageUrl: receiptImageUrl ?? this.receiptImageUrl,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
