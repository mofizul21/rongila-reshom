import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class AccountProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<AccountTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _transactionsSubscription;

  List<AccountTransaction> get transactions => _transactions;

  List<AccountTransaction> get deposits =>
      _transactions.where((t) => t.type == TransactionType.deposit).toList();

  List<AccountTransaction> get withdrawals =>
      _transactions.where((t) => t.type == TransactionType.withdraw).toList();

  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalDeposits =>
      deposits.fold(0, (sum, t) => sum + t.amount);

  double get totalWithdrawals =>
      withdrawals.fold(0, (sum, t) => sum + t.amount);

  double get netBalance => totalDeposits - totalWithdrawals;

  AccountProvider() {
    _initTransactionsStream();
  }

  void _initTransactionsStream() {
    _transactionsSubscription =
        _databaseService.accountTransactionsStream.listen((transactions) {
      _transactions = transactions;
      notifyListeners();
    }, onError: (error) {
      // Ignore errors (e.g., permission denied after logout)
    });
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addTransaction({
    required TransactionType type,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final transaction = AccountTransaction(
        id: const Uuid().v4(),
        type: type,
        amount: amount,
        date: date,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addAccountTransaction(transaction);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTransaction({
    required String id,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final transaction = getTransactionById(id);
      if (transaction == null) {
        _isLoading = false;
        _error = 'Transaction not found';
        notifyListeners();
        return;
      }

      final updatedTransaction = transaction.copyWith(
        amount: amount,
        date: date,
        note: note,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateAccountTransaction(updatedTransaction);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.deleteAccountTransaction(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  AccountTransaction? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
