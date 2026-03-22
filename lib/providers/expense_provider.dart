import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _error;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ExpenseProvider() {
    _initExpensesStream();
  }

  void _initExpensesStream() {
    _databaseService.expensesStream.listen((expenses) {
      _expenses = expenses;
      notifyListeners();
    });
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required String category,
    String? description,
    required DateTime date,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final expense = Expense(
        id: const Uuid().v4(),
        title: title,
        amount: amount,
        category: category,
        description: description,
        date: date,
        createdAt: DateTime.now(),
      );

      await _databaseService.addExpense(expense);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    String? description,
    required DateTime date,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final expense = getExpenseById(id);
      if (expense == null) return;

      final updatedExpense = expense.copyWith(
        title: title,
        amount: amount,
        category: category,
        description: description,
        date: date,
      );

      await _databaseService.updateExpense(updatedExpense);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _databaseService.deleteExpense(expenseId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Expense? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((expense) => expense.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
