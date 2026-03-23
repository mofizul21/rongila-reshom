import 'package:cloud_firestore/cloud_firestore.dart';

enum StockMovementType { stockIn, stockOut }

class StockMovement {
  final String id;
  final String productId;
  final String productName;
  final String? categoryId;
  final String? categoryName;
  final StockMovementType movementType;
  final int quantity;
  final String? reason; // For notes: "New stock", "Order #123", etc.
  final String? orderId; // Reference to order if stock-out
  final DateTime createdAt;
  final String createdBy; // User ID

  StockMovement({
    required this.id,
    required this.productId,
    required this.productName,
    this.categoryId,
    this.categoryName,
    required this.movementType,
    required this.quantity,
    this.reason,
    this.orderId,
    required this.createdAt,
    required this.createdBy,
  });

  factory StockMovement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockMovement(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      movementType: StockMovementType.values.firstWhere(
        (e) => e.toString() == 'StockMovementType.${data['movementType']}',
        orElse: () => StockMovementType.stockIn,
      ),
      quantity: data['quantity'] ?? 0,
      reason: data['reason'],
      orderId: data['orderId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'movementType': movementType.toString().split('.').last,
      'quantity': quantity,
      'reason': reason,
      'orderId': orderId,
      'createdAt': Timestamp.fromDate(createdAt),
      'createdBy': createdBy,
    };
  }

  StockMovement copyWith({
    String? id,
    String? productId,
    String? productName,
    String? categoryId,
    String? categoryName,
    StockMovementType? movementType,
    int? quantity,
    String? reason,
    String? orderId,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return StockMovement(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      movementType: movementType ?? this.movementType,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
