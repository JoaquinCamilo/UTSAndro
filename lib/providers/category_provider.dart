import 'package:flutter/foundation.dart' as foundation;
import '../models/category.dart';
import '../services/realtime_database_service.dart';

class CategoryProvider with foundation.ChangeNotifier {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _databaseService.getCategories();
    } catch (e) {
      _error = 'Failed to load categories: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    try {
      await _databaseService.addCategory(category);
      _categories.add(category);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add category: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _databaseService.updateCategory(category);
      final index = _categories.indexWhere((c) => c.id == category.id);
      if (index != -1) {
        _categories[index] = category;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update category: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _databaseService.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete category: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  List<Category> getIncomeCategories() {
    return _categories.where((c) => c.type == 'income').toList();
  }

  List<Category> getExpenseCategories() {
    return _categories.where((c) => c.type == 'expense').toList();
  }

  List<Category> getDefaultCategories() {
    return _categories.where((c) => c.isDefault).toList();
  }

  List<Category> getCustomCategories() {
    return _categories.where((c) => !c.isDefault).toList();
  }
} 