import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double totalDue;
  final List<String> orderIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.totalDue = 0,
    this.orderIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final orderIdsData = data['orderIds'] as List<dynamic>? ?? [];
    final orderIds = orderIdsData.map((e) => e.toString()).toList();

    return Customer(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      totalDue: (data['totalDue'] ?? 0).toDouble(),
      orderIds: orderIds,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'totalDue': totalDue,
      'orderIds': orderIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    double? totalDue,
    List<String>? orderIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      totalDue: totalDue ?? this.totalDue,
      orderIds: orderIds ?? this.orderIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
