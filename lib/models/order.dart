import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, completed, delivered }

class OrderItem {
  final String productId;
  final String productName;
  final double salePrice;
  final int quantity;
  final double total;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.salePrice,
    required this.quantity,
    required this.total,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'salePrice': salePrice,
      'quantity': quantity,
      'total': total,
    };
  }

  factory OrderItem.fromFirestore(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      salePrice: (data['salePrice'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      total: (data['total'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<OrderItem> items;
  final double totalAmount;
  final double depositAmount;
  final double dueAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.totalAmount,
    required this.depositAmount,
    required this.dueAmount,
    required this.orderDate,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((e) => OrderItem.fromFirestore(e as Map<String, dynamic>)).toList();

    return OrderModel(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      items: items,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      depositAmount: (data['depositAmount'] ?? 0).toDouble(),
      dueAmount: (data['dueAmount'] ?? 0).toDouble(),
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == 'OrderStatus.${data['status']}',
        orElse: () => OrderStatus.pending,
      ),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((e) => e.toFirestore()).toList(),
      'totalAmount': totalAmount,
      'depositAmount': depositAmount,
      'dueAmount': dueAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'status': status.toString().split('.').last,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<OrderItem>? items,
    double? totalAmount,
    double? depositAmount,
    double? dueAmount,
    DateTime? orderDate,
    OrderStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      depositAmount: depositAmount ?? this.depositAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
