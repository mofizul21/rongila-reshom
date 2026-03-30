import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class SupplierProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Supplier> _suppliers = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _suppliersSubscription;

  List<Supplier> get suppliers => _suppliers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SupplierProvider() {
    _initSuppliersStream();
  }

  void _initSuppliersStream() {
    _suppliersSubscription = _databaseService.suppliersStream.listen((suppliers) {
      _suppliers = suppliers;
      notifyListeners();
    }, onError: (error) {
      // Ignore errors (e.g., permission denied after logout)
    });
  }

  @override
  void dispose() {
    _suppliersSubscription?.cancel();
    super.dispose();
  }

  Future<void> addSupplier({
    required String name,
    required String phone,
    required String address,
    String? receiptImageUrl,
    required DateTime date,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final supplier = Supplier(
        id: const Uuid().v4(),
        name: name,
        phone: phone,
        address: address,
        receiptImageUrl: receiptImageUrl,
        date: date,
        totalAmount: totalAmount,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _databaseService.addSupplier(supplier);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateSupplier({
    required String id,
    required String name,
    required String phone,
    required String address,
    String? receiptImageUrl,
    required DateTime date,
    required double totalAmount,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final supplier = getSupplierById(id);
      if (supplier == null) return;

      final updatedSupplier = supplier.copyWith(
        name: name,
        phone: phone,
        address: address,
        receiptImageUrl: receiptImageUrl,
        date: date,
        totalAmount: totalAmount,
        notes: notes,
      );

      await _databaseService.updateSupplier(updatedSupplier);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _databaseService.deleteSupplier(supplierId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Supplier? getSupplierById(String id) {
    try {
      return _suppliers.firstWhere((supplier) => supplier.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
