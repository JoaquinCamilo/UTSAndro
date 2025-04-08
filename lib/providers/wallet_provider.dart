import 'package:flutter/foundation.dart';
import '../models/wallet.dart';
import '../services/realtime_database_service.dart';

class WalletProvider with ChangeNotifier {
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  List<Wallet?> _wallets = [];
  bool _isLoading = false;
  String? _error;

  List<Wallet?> get wallets => _wallets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWallets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _wallets = await _databaseService.getWallets();
    } catch (e) {
      _error = 'Failed to load wallets: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWallet(Wallet wallet) async {
    try {
      await _databaseService.addWallet(wallet);
      _wallets.add(wallet);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add wallet: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> updateWallet(Wallet wallet) async {
    try {
      await _databaseService.updateWallet(wallet);
      final index = _wallets.indexWhere((w) => w?.id == wallet.id);
      if (index != -1) {
        _wallets[index] = wallet;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update wallet: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> deleteWallet(String walletId) async {
    try {
      await _databaseService.deleteWallet(walletId);
      _wallets.removeWhere((w) => w?.id == walletId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete wallet: $e';
      notifyListeners();
      throw Exception(_error);
    }
  }

  Wallet? getWalletById(String walletId) {
    try {
      return _wallets.firstWhere((w) => w?.id == walletId);
    } catch (e) {
      return null;
    }
  }

  Wallet? getDefaultWallet() {
    try {
      return _wallets.firstWhere((w) => w?.isDefault == true);
    } catch (e) {
      return null;
    }
  }

  double getTotalBalance() {
    return _wallets.fold(0.0, (sum, w) => sum + (w?.balance ?? 0));
  }
} 