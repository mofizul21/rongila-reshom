import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentTransaction {
  final String id;
  final double amount;
  final DateTime paymentDate;
  final String? note;
  final DateTime createdAt;

  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.note,
    required this.createdAt,
  });

  factory PaymentTransaction.fromFirestore(Map<String, dynamic> data) {
    return PaymentTransaction(
      id: data['id'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
      note: data['note'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PaymentTransaction copyWith({
    String? id,
    double? amount,
    DateTime? paymentDate,
    String? note,
    DateTime? createdAt,
  }) {
    return PaymentTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
