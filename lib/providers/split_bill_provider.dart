import 'package:flutter/foundation.dart';
import '../models/split_bill.dart';
import '../services/realtime_database_service.dart';

class SplitBillProvider with ChangeNotifier {
  final RealtimeDatabaseService _databaseService;
  List<SplitBill> _splitBills = [];
  bool _isLoading = false;
  String? _error;

  SplitBillProvider(this._databaseService);

  List<SplitBill> get splitBills => _splitBills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSplitBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _splitBills = await _databaseService.getSplitBills();
    } catch (e) {
      _error = 'Gagal memuat tagihan bersama: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSplitBill(SplitBill splitBill) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.addSplitBill(splitBill);
      _splitBills.add(splitBill);
    } catch (e) {
      _error = 'Gagal menambah tagihan bersama: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSplitBill(SplitBill splitBill) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.updateSplitBill(splitBill);
      final index = _splitBills.indexWhere((sb) => sb.id == splitBill.id);
      if (index != -1) {
        _splitBills[index] = splitBill;
      }
    } catch (e) {
      _error = 'Gagal memperbarui tagihan bersama: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSplitBill(String splitBillId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.deleteSplitBill(splitBillId);
      _splitBills.removeWhere((splitBill) => splitBill.id == splitBillId);
    } catch (e) {
      _error = 'Gagal menghapus tagihan bersama: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markSplitBillAsPaid(String splitBillId) async {
    final splitBill = _splitBills.firstWhere((sb) => sb.id == splitBillId);
    final updatedSplitBill = splitBill.copyWith(isPaid: true);
    await updateSplitBill(updatedSplitBill);
  }

  Future<void> markSplitBillAsUnpaid(String splitBillId) async {
    final splitBill = _splitBills.firstWhere((sb) => sb.id == splitBillId);
    final updatedSplitBill = splitBill.copyWith(isPaid: false);
    await updateSplitBill(updatedSplitBill);
  }

  List<SplitBill> getCreatedSplitBills() {
    return _splitBills.where((splitBill) => splitBill.createdBy == _databaseService.currentUserId).toList();
  }

  List<SplitBill> getParticipatedSplitBills() {
    return _splitBills.where((splitBill) => splitBill.participantIds.contains(_databaseService.currentUserId)).toList();
  }

  List<SplitBill> getPaidSplitBills() {
    return _splitBills.where((splitBill) => splitBill.isPaid).toList();
  }

  List<SplitBill> getUnpaidSplitBills() {
    return _splitBills.where((splitBill) => !splitBill.isPaid).toList();
  }
} 