import 'package:flutter/foundation.dart';
import '../models/debt.dart';
import '../services/realtime_database_service.dart';

class DebtProvider with ChangeNotifier {
  final RealtimeDatabaseService _databaseService;
  List<Debt> _debts = [];
  bool _isLoading = false;
  String? _error;

  DebtProvider(this._databaseService);

  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDebts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _debts = await _databaseService.getDebts();
    } catch (e) {
      _error = 'Gagal memuat hutang: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDebt(Debt debt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.addDebt(debt);
      _debts.add(debt);
    } catch (e) {
      _error = 'Gagal menambah hutang: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDebt(Debt debt) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.updateDebt(debt);
      final index = _debts.indexWhere((d) => d.id == debt.id);
      if (index != -1) {
        _debts[index] = debt;
      }
    } catch (e) {
      _error = 'Gagal memperbarui hutang: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDebt(String debtId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.deleteDebt(debtId);
      _debts.removeWhere((debt) => debt.id == debtId);
    } catch (e) {
      _error = 'Gagal menghapus hutang: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markDebtAsPaid(String debtId) async {
    final debt = _debts.firstWhere((d) => d.id == debtId);
    final updatedDebt = debt.copyWith(isPaid: true);
    await updateDebt(updatedDebt);
  }

  Future<void> markDebtAsUnpaid(String debtId) async {
    final debt = _debts.firstWhere((d) => d.id == debtId);
    final updatedDebt = debt.copyWith(isPaid: false);
    await updateDebt(updatedDebt);
  }

  List<Debt> getBorrowedDebts() {
    return _debts.where((debt) => !debt.isLender).toList();
  }

  List<Debt> getLentDebts() {
    return _debts.where((debt) => debt.isLender).toList();
  }

  List<Debt> getPaidDebts() {
    return _debts.where((debt) => debt.isPaid).toList();
  }

  List<Debt> getUnpaidDebts() {
    return _debts.where((debt) => !debt.isPaid).toList();
  }
} 