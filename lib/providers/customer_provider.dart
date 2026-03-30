import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class CustomerProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _customersSubscription;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CustomerProvider() {
    _initCustomersStream();
  }

  void _initCustomersStream() {
    _customersSubscription = _databaseService.customersStream.listen((customers) {
      _customers = customers;
      notifyListeners();
    }, onError: (error) {
      // Ignore errors (e.g., permission denied after logout)
    });
  }

  @override
  void dispose() {
    _customersSubscription?.cancel();
    super.dispose();
  }

  Future<void> addCustomer({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final customer = Customer(
        id: const Uuid().v4(),
        name: name,
        phone: phone,
        address: address,
        totalDue: 0,
        orderIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addCustomer(customer);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final customer = getCustomerById(id);
      if (customer == null) return;

      final updatedCustomer = customer.copyWith(
        name: name,
        phone: phone,
        address: address,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateCustomer(updatedCustomer);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _databaseService.deleteCustomer(customerId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      return await _databaseService.searchCustomers(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((customer) => customer.id == id);
    } catch (e) {
      return null;
    }
  }

  Customer? getCustomerByPhone(String phone) {
    try {
      return _customers.firstWhere((customer) => customer.phone == phone);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
