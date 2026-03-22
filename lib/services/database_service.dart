import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ Products ============
  Stream<List<Product>> get productsStream {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getProductsByCategory(String categoryId) {
    return _firestore
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Future<List<Product>> searchProducts(String query) async {
    final snapshot = await _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .get();

    final products = snapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .where((product) =>
            product.title.toLowerCase().contains(query.toLowerCase()) ||
            (product.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    return products;
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).set(
          product.toFirestore(),
        );
  }

  Future<void> updateProduct(Product product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // ============ Categories ============
  Stream<List<CategoryModel>> get categoriesStream {
    return _firestore
        .collection('categories')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList());
  }

  Future<void> addCategory(CategoryModel category) async {
    await _firestore.collection('categories').doc(category.id).set(
          category.toFirestore(),
        );
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _firestore
        .collection('categories')
        .doc(category.id)
        .update(category.toFirestore());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }

  // ============ Orders ============
  Stream<List<OrderModel>> get ordersStream {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Future<List<OrderModel>> searchOrders(String query) async {
    final snapshot = await _firestore.collection('orders').get();

    final orders = snapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .where((order) =>
            order.customerName.toLowerCase().contains(query.toLowerCase()) ||
            order.customerPhone.contains(query))
        .toList();

    return orders;
  }

  Future<void> addOrder(OrderModel order) async {
    await _firestore.collection('orders').doc(order.id).set(
          order.toFirestore(),
        );
  }

  Future<void> updateOrder(OrderModel order) async {
    await _firestore
        .collection('orders')
        .doc(order.id)
        .update(order.toFirestore());
  }

  Future<void> deleteOrder(String orderId) async {
    await _firestore.collection('orders').doc(orderId).delete();
  }

  // ============ Customers ============
  Stream<List<Customer>> get customersStream {
    return _firestore
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final snapshot = await _firestore.collection('customers').get();

    final customers = snapshot.docs
        .map((doc) => Customer.fromFirestore(doc))
        .where((customer) =>
            customer.name.toLowerCase().contains(query.toLowerCase()) ||
            customer.phone.contains(query))
        .toList();

    return customers;
  }

  Future<void> addCustomer(Customer customer) async {
    await _firestore.collection('customers').doc(customer.id).set(
          customer.toFirestore(),
        );
  }

  Future<void> updateCustomer(Customer customer) async {
    await _firestore
        .collection('customers')
        .doc(customer.id)
        .update(customer.toFirestore());
  }

  Future<void> deleteCustomer(String customerId) async {
    await _firestore.collection('customers').doc(customerId).delete();
  }

  Future<Customer?> getCustomerById(String customerId) async {
    final doc =
        await _firestore.collection('customers').doc(customerId).get();
    if (doc.exists) {
      return Customer.fromFirestore(doc);
    }
    return null;
  }

  // ============ Notes ============
  Stream<List<Note>> get notesStream {
    return _firestore
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Note.fromFirestore(doc)).toList());
  }

  Future<List<Note>> searchNotes(String query) async {
    final snapshot = await _firestore.collection('notes').get();

    final notes = snapshot.docs
        .map((doc) => Note.fromFirestore(doc))
        .where((note) =>
            note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return notes;
  }

  Future<void> addNote(Note note) async {
    await _firestore.collection('notes').doc(note.id).set(
          note.toFirestore(),
        );
  }

  Future<void> updateNote(Note note) async {
    await _firestore
        .collection('notes')
        .doc(note.id)
        .update(note.toFirestore());
  }

  Future<void> deleteNote(String noteId) async {
    await _firestore.collection('notes').doc(noteId).delete();
  }

  // ============ Suppliers ============
  Stream<List<Supplier>> get suppliersStream {
    return _firestore
        .collection('suppliers')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Supplier.fromFirestore(doc)).toList());
  }

  Future<void> addSupplier(Supplier supplier) async {
    await _firestore.collection('suppliers').doc(supplier.id).set(
          supplier.toFirestore(),
        );
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await _firestore
        .collection('suppliers')
        .doc(supplier.id)
        .update(supplier.toFirestore());
  }

  Future<void> deleteSupplier(String supplierId) async {
    await _firestore.collection('suppliers').doc(supplierId).delete();
  }

  // ============ Expenses ============
  Stream<List<Expense>> get expensesStream {
    return _firestore
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> addExpense(Expense expense) async {
    await _firestore.collection('expenses').doc(expense.id).set(
          expense.toFirestore(),
        );
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestore
        .collection('expenses')
        .doc(expense.id)
        .update(expense.toFirestore());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }

  // ============ Reports ============
  Future<Map<String, dynamic>> getReports({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime(2000);
    final end = endDate ?? DateTime(2100);

    final ordersSnapshot = await _firestore.collection('orders').get();
    final productsSnapshot = await _firestore.collection('products').get();
    final expensesSnapshot = await _firestore.collection('expenses').get();

    final orders = ordersSnapshot.docs
        .map((doc) => OrderModel.fromFirestore(doc))
        .where((order) =>
            order.orderDate.isAfter(start) &&
            order.orderDate.isBefore(end))
        .toList();

    final products = productsSnapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList();

    final expenses = expensesSnapshot.docs
        .map((doc) => Expense.fromFirestore(doc))
        .where((expense) =>
            expense.date.isAfter(start) &&
            expense.date.isBefore(end))
        .toList();

    double totalSales = orders.fold(0, (total, order) => total + order.totalAmount);
    double totalPurchase =
        products.fold(0, (total, product) => total + product.totalValue);
    double totalExpenses =
        expenses.fold(0, (total, expense) => total + expense.amount);
    double totalDue = orders.fold(0, (total, order) => total + order.dueAmount);
    double totalDeposit =
        orders.fold(0, (total, order) => total + order.depositAmount);

    // Calculate profit: Sales - Purchase cost of sold items
    double totalProfit = totalSales - totalPurchase - totalExpenses;

    return {
      'totalSales': totalSales,
      'totalPurchase': totalPurchase,
      'totalProfit': totalProfit,
      'totalDue': totalDue,
      'totalDeposit': totalDeposit,
      'totalExpenses': totalExpenses,
      'totalOrders': orders.length,
      'totalProducts': products.length,
    };
  }

  // ============ Payment History ============
  Stream<List<Map<String, dynamic>>> get paymentHistoryStream {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final order = OrderModel.fromFirestore(doc);
              return {
                'orderId': order.id,
                'customerName': order.customerName,
                'orderDate': order.orderDate,
                'totalAmount': order.totalAmount,
                'depositAmount': order.depositAmount,
                'dueAmount': order.dueAmount,
                'status': order.status,
              };
            }).toList());
  }

  Future<List<Map<String, dynamic>>> getPaymentHistoryByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snapshot = await _firestore.collection('orders').get();

    final payments = snapshot.docs
        .map((doc) {
          final order = OrderModel.fromFirestore(doc);
          return {
            'orderId': order.id,
            'customerName': order.customerName,
            'orderDate': order.orderDate,
            'totalAmount': order.totalAmount,
            'depositAmount': order.depositAmount,
            'dueAmount': order.dueAmount,
            'status': order.status,
          };
        })
        .where((payment) {
          final orderDate = payment['orderDate'] as DateTime;
          return orderDate.isAfter(startDate) && orderDate.isBefore(endDate);
        })
        .toList();

    return payments;
  }
}
