import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final double purchasePrice;
  final double salePrice;
  final int quantity;
  final String? imageUrl;
  final String? categoryId;
  final String? categoryName;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.title,
    required this.purchasePrice,
    required this.salePrice,
    required this.quantity,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      purchasePrice: (data['purchasePrice'] ?? 0).toDouble(),
      salePrice: (data['salePrice'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 0,
      imageUrl: data['imageUrl'],
      categoryId: data['categoryId'],
      categoryName: data['categoryName'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Product copyWith({
    String? id,
    String? title,
    double? purchasePrice,
    double? salePrice,
    int? quantity,
    String? imageUrl,
    String? categoryId,
    String? categoryName,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get profit => salePrice - purchasePrice;
  double get totalValue => purchasePrice * quantity;
}
