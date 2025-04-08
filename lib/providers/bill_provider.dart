import 'package:flutter/foundation.dart';
import '../models/bill.dart';
import '../services/realtime_database_service.dart';

class BillProvider with ChangeNotifier {
  final RealtimeDatabaseService _databaseService;
  List<Bill> _bills = [];
  bool _isLoading = false;
  String? _error;

  BillProvider(this._databaseService);

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bills = await _databaseService.getBills();
    } catch (e) {
      _error = 'Gagal memuat tagihan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBill(Bill bill) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.addBill(bill);
      _bills.add(bill);
    } catch (e) {
      _error = 'Gagal menambah tagihan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBill(Bill bill) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.updateBill(bill);
      final index = _bills.indexWhere((b) => b.id == bill.id);
      if (index != -1) {
        _bills[index] = bill;
      }
    } catch (e) {
      _error = 'Gagal memperbarui tagihan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBill(String billId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _databaseService.deleteBill(billId);
      _bills.removeWhere((bill) => bill.id == billId);
    } catch (e) {
      _error = 'Gagal menghapus tagihan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markBillAsPaid(String billId) async {
    final bill = _bills.firstWhere((b) => b.id == billId);
    final updatedBill = bill.copyWith(isPaid: true);
    await updateBill(updatedBill);
  }

  Future<void> markBillAsUnpaid(String billId) async {
    final bill = _bills.firstWhere((b) => b.id == billId);
    final updatedBill = bill.copyWith(isPaid: false);
    await updateBill(updatedBill);
  }
} 