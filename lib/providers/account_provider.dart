import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class AccountProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Withdrawal> _withdrawals = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _withdrawalsSubscription;

  List<Withdrawal> get withdrawals => _withdrawals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalWithdrawals =>
      _withdrawals.fold(0, (sum, w) => sum + w.amount);

  AccountProvider() {
    _initWithdrawalsStream();
  }

  void _initWithdrawalsStream() {
    _withdrawalsSubscription =
        _databaseService.withdrawalsStream.listen((withdrawals) {
      _withdrawals = withdrawals;
      notifyListeners();
    }, onError: (error) {
      // Ignore errors (e.g., permission denied after logout)
    });
  }

  @override
  void dispose() {
    _withdrawalsSubscription?.cancel();
    super.dispose();
  }

  Future<void> addWithdrawal({
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final withdrawal = Withdrawal(
        id: const Uuid().v4(),
        amount: amount,
        date: date,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.addWithdrawal(withdrawal);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateWithdrawal({
    required String id,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final withdrawal = getWithdrawalById(id);
      if (withdrawal == null) {
        _isLoading = false;
        _error = 'Withdrawal not found';
        notifyListeners();
        return;
      }

      final updatedWithdrawal = withdrawal.copyWith(
        amount: amount,
        date: date,
        note: note,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateWithdrawal(updatedWithdrawal);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteWithdrawal(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.deleteWithdrawal(id);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Withdrawal? getWithdrawalById(String id) {
    try {
      return _withdrawals.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
