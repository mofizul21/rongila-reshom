import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/services.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Default categories
  static const List<String> defaultCategories = [
    '3-piece',
    'Sharee',
    'Sit-kapor',
    'Lungi',
    'Others',
  ];

  CategoryProvider() {
    _initCategoriesStream();
  }

  void _initCategoriesStream() {
    _databaseService.categoriesStream.listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  Future<void> addCategory({
    required String name,
    String? description,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final category = CategoryModel(
        id: const Uuid().v4(),
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );

      await _databaseService.addCategory(category);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    String? description,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final category = getCategoryById(id);
      if (category == null) return;

      final updatedCategory = category.copyWith(
        name: name,
        description: description,
      );

      await _databaseService.updateCategory(updatedCategory);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _databaseService.deleteCategory(categoryId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
