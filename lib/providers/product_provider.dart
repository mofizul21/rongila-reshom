import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _productsSubscription;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProductProvider() {
    _initProductsStream();
  }

  void _initProductsStream() {
    _productsSubscription = _databaseService.productsStream.listen((products) {
      _products = products;
      notifyListeners();
    }, onError: (error) {
      // Ignore errors (e.g., permission denied after logout)
    });
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addProduct({
    required String title,
    required double purchasePrice,
    required int quantity,
    String? imageUrl,
    String? categoryId,
    String? categoryName,
    String? description,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final product = Product(
        id: const Uuid().v4(),
        title: title,
        purchasePrice: purchasePrice,
        quantity: quantity,
        imageUrl: imageUrl,
        categoryId: categoryId,
        categoryName: categoryName,
        description: description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addProduct(product);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProduct({
    required String id,
    required String title,
    required double purchasePrice,
    required int quantity,
    String? imageUrl,
    String? categoryId,
    String? categoryName,
    String? description,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final product = getProductById(id);
      if (product == null) return;

      final updatedProduct = product.copyWith(
        title: title,
        purchasePrice: purchasePrice,
        quantity: quantity,
        imageUrl: imageUrl,
        categoryId: categoryId,
        categoryName: categoryName,
        description: description,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateProduct(updatedProduct);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _databaseService.deleteProduct(productId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> duplicateProduct(Product product) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newProduct = Product(
        id: const Uuid().v4(),
        title: '${product.title} (Copy)',
        purchasePrice: product.purchasePrice,
        quantity: product.quantity,
        imageUrl: product.imageUrl,
        categoryId: product.categoryId,
        categoryName: product.categoryName,
        description: product.description,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addProduct(newProduct);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _databaseService.searchProducts(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<void> updateProductQuantity(String productId, int quantityChange) async {
    try {
      final product = getProductById(productId);
      if (product == null) return;

      final updatedProduct = product.copyWith(
        quantity: product.quantity + quantityChange,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateProduct(updatedProduct);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
