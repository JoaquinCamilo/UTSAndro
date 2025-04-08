import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../services/realtime_database_service.dart';

class GoalProvider with ChangeNotifier {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  List<Goal> _goals = [];
  bool _isLoading = false;
  String? _error;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGoals() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _goals = await _databaseService.getGoals();
    } catch (e) {
      _error = 'Failed to load goals: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal(Goal goal) async {
    try {
      await _databaseService.addGoal(goal);
      _goals.add(goal);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add goal: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await _databaseService.updateGoal(goal);
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update goal: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _databaseService.deleteGoal(goalId);
      _goals.removeWhere((g) => g.id == goalId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete goal: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Goal? getGoalById(String goalId) {
    try {
      return _goals.firstWhere((g) => g.id == goalId);
    } catch (e) {
      return null;
    }
  }

  List<Goal> getCompletedGoals() {
    return _goals.where((g) => g.isCompleted).toList();
  }

  List<Goal> getInProgressGoals() {
    return _goals.where((g) => !g.isCompleted).toList();
  }

  double getTotalTargetAmount() {
    return _goals.fold(0, (sum, g) => sum + g.targetAmount);
  }

  double getTotalCurrentAmount() {
    return _goals.fold(0, (sum, g) => sum + g.currentAmount);
  }

  double getTotalProgress() {
    final totalTarget = getTotalTargetAmount();
    if (totalTarget == 0) return 0;
    return getTotalCurrentAmount() / totalTarget;
  }
} 