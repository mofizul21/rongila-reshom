import 'package:flutter/foundation.dart';
import '../services/services.dart';

class ReportProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  Map<String, dynamic> _reports = {};
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalSales => _reports['totalSales'] ?? 0.0;
  double get totalPurchase => _reports['totalPurchase'] ?? 0.0;
  double get totalProfit => _reports['totalProfit'] ?? 0.0;
  double get totalDue => _reports['totalDue'] ?? 0.0;
  double get totalDeposit => _reports['totalDeposit'] ?? 0.0;
  double get totalExpenses => _reports['totalExpenses'] ?? 0.0;
  int get totalOrders => _reports['totalOrders'] ?? 0;
  int get totalProducts => _reports['totalProducts'] ?? 0;

  ReportProvider() {
    _loadReports();
  }

  Future<void> _loadReports() async {
    try {
      _isLoading = true;
      notifyListeners();

      _reports = await _databaseService.getReports();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadReportsByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      _reports = await _databaseService.getReports(
        startDate: startDate,
        endDate: endDate,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
