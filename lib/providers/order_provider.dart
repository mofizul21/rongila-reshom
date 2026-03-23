import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  OrderProvider() {
    _initOrdersStream();
  }

  void _initOrdersStream() {
    _databaseService.ordersStream.listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  Future<void> addOrder({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required List<OrderItem> items,
    required double totalAmount,
    required double depositAmount,
    required DateTime orderDate,
    OrderStatus status = OrderStatus.pending,
    String? notes,
    String? orderId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final dueAmount = totalAmount - depositAmount;
      final newOrderId = orderId ?? const Uuid().v4();

      final order = OrderModel(
        id: newOrderId,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        items: items,
        totalAmount: totalAmount,
        depositAmount: depositAmount,
        dueAmount: dueAmount,
        orderDate: orderDate,
        status: status,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addOrder(order);

      // Update product quantities
      for (var item in items) {
        await _databaseService.updateProductQuantity(item.productId, -item.quantity);
      }

      // Update customer with order ID
      await _updateCustomerWithOrder(
        customerPhone,
        customerName,
        customerAddress,
        dueAmount,
        newOrderId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateOrder({
    required String id,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required List<OrderItem> items,
    required double totalAmount,
    required double depositAmount,
    required DateTime orderDate,
    required OrderStatus status,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final order = getOrderById(id);
      if (order == null) return;

      final dueAmount = totalAmount - depositAmount;
      final previousDue = order.dueAmount;
      final previousPhone = order.customerPhone;

      final updatedOrder = order.copyWith(
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
        items: items,
        totalAmount: totalAmount,
        depositAmount: depositAmount,
        dueAmount: dueAmount,
        orderDate: orderDate,
        status: status,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateOrder(updatedOrder);

      // Update customer's total due and phone if changed
      await _updateCustomerDueAfterEdit(
        previousPhone,
        customerPhone,
        previousDue,
        dueAmount,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      final order = getOrderById(orderId);
      if (order != null) {
        // Remove order ID from customer and update due
        await _removeOrderFromCustomer(order.customerPhone, orderId, order.dueAmount);
        
        // Restore product quantities
        for (var item in order.items) {
          await _databaseService.updateProductQuantity(item.productId, item.quantity);
        }
      }
      await _databaseService.deleteOrder(orderId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _removeOrderFromCustomer(
    String phone,
    String orderId,
    double dueAmount,
  ) async {
    final customersSnapshot = await _databaseService.customersStream.first;
    
    try {
      final customer = customersSnapshot.firstWhere((c) => c.phone == phone);
      final orderIds = List<String>.from(customer.orderIds)..remove(orderId);
      final updatedDue = customer.totalDue - dueAmount;
      
      final updatedCustomer = customer.copyWith(
        totalDue: updatedDue >= 0 ? updatedDue : 0,
        orderIds: orderIds,
        updatedAt: DateTime.now(),
      );
      await _databaseService.updateCustomer(updatedCustomer);
    } catch (e) {
      // Customer not found, skip update
    }
  }

  Future<void> duplicateOrder(OrderModel order) async {
    try {
      _isLoading = true;
      notifyListeners();

      final newOrderId = const Uuid().v4();
      
      final newOrder = OrderModel(
        id: newOrderId,
        customerName: order.customerName,
        customerPhone: order.customerPhone,
        customerAddress: order.customerAddress,
        items: order.items,
        totalAmount: order.totalAmount,
        depositAmount: 0, // Reset deposit for new order
        dueAmount: order.totalAmount, // Full amount as due
        orderDate: DateTime.now(),
        status: OrderStatus.pending,
        notes: order.notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addOrder(newOrder);
      
      // Add order ID to customer
      await _updateCustomerWithOrder(
        order.customerPhone,
        order.customerName,
        order.customerAddress,
        order.totalAmount,
        newOrderId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<OrderModel>> searchOrders(String query) async {
    try {
      return await _databaseService.searchOrders(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  OrderModel? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateCustomerWithOrder(
    String phone,
    String name,
    String address,
    double dueAmount,
    String orderId,
  ) async {
    final customersSnapshot = await _databaseService.customersStream.first;
    final customer = customersSnapshot.firstWhere(
      (c) => c.phone == phone,
      orElse: () => Customer(
        id: '',
        name: '',
        phone: phone,
        address: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    if (customer.id.isEmpty) {
      // Create new customer with order ID
      final newCustomer = Customer(
        id: const Uuid().v4(),
        name: name,
        phone: phone,
        address: address,
        totalDue: dueAmount,
        orderIds: [orderId],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _databaseService.addCustomer(newCustomer);
    } else {
      // Update existing customer with order ID
      final orderIds = List<String>.from(customer.orderIds)..add(orderId);
      final updatedCustomer = customer.copyWith(
        totalDue: customer.totalDue + dueAmount,
        orderIds: orderIds,
        updatedAt: DateTime.now(),
      );
      await _databaseService.updateCustomer(updatedCustomer);
    }
  }

  Future<void> _updateCustomerDueAfterEdit(
    String previousPhone,
    String newPhone,
    double previousDue,
    double newDue,
  ) async {
    final customersSnapshot = await _databaseService.customersStream.first;
    
    try {
      // Find customer by previous phone
      Customer customer = customersSnapshot.firstWhere(
        (c) => c.phone == previousPhone,
      );
      
      // Update due amount
      final updatedDue = customer.totalDue - previousDue + newDue;
      var updatedCustomer = customer.copyWith(
        totalDue: updatedDue,
        updatedAt: DateTime.now(),
      );
      
      // If phone changed, update phone and potentially merge customers
      if (previousPhone != newPhone) {
        updatedCustomer = updatedCustomer.copyWith(phone: newPhone);
      }
      
      await _databaseService.updateCustomer(updatedCustomer);
    } catch (e) {
      // Customer not found, skip update
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
