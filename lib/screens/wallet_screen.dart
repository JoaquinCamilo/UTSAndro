import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/debt.dart';
import '../models/split_bill.dart';
import '../services/realtime_database_service.dart';

class WalletScreen extends StatefulWidget {
  final Function(Debt)? onDebtAdded;
  
  const WalletScreen({
    super.key,
    this.onDebtAdded,
  });

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();
  
  // Add global state for debts and split bills
  List<Debt> _debts = [];
  List<SplitBill> _splitBills = [];

  // Text controllers for forms
  final TextEditingController _debtTitleController = TextEditingController();
  final TextEditingController _debtAmountController = TextEditingController();
  final TextEditingController _debtNotesController = TextEditingController();
  final TextEditingController _debtContactNameController = TextEditingController();
  final TextEditingController _debtContactPhoneController = TextEditingController();

  final TextEditingController _splitBillTitleController = TextEditingController();
  final TextEditingController _splitBillAmountController = TextEditingController();
  final TextEditingController _splitBillNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _debtTitleController.dispose();
    _debtAmountController.dispose();
    _debtNotesController.dispose();
    _debtContactNameController.dispose();
    _debtContactPhoneController.dispose();
    _splitBillTitleController.dispose();
    _splitBillAmountController.dispose();
    _splitBillNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final debts = await _databaseService.getDebts();
      final splitBills = await _databaseService.getSplitBills();
      setState(() {
        _debts = debts;
        _splitBills = splitBills;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  void addDebt(Debt debt) async {
    try {
      // Save to Firebase first
      await _databaseService.addDebt(debt);
      
      // Then update local state and notify parent
      setState(() {
        _debts.add(debt);
      });
      
      // Notify parent widget
      widget.onDebtAdded?.call(debt);
      
      // Clear controllers
      _debtTitleController.clear();
      _debtAmountController.clear();
      _debtNotesController.clear();
      _debtContactNameController.clear();
      _debtContactPhoneController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding debt: $e')),
        );
      }
    }
  }

  void _addSplitBill(SplitBill splitBill) async {
    try {
      await _databaseService.addSplitBill(splitBill);
      setState(() {
        _splitBills.add(splitBill);
      });
      _clearSplitBillControllers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding split bill: $e')),
        );
      }
    }
  }

  void _clearDebtControllers() {
    _debtTitleController.clear();
    _debtAmountController.clear();
    _debtNotesController.clear();
    _debtContactNameController.dispose();
    _debtContactPhoneController.dispose();
  }

  void _clearSplitBillControllers() {
    _splitBillTitleController.clear();
    _splitBillAmountController.clear();
    _splitBillNotesController.clear();
  }

  void _showAddDebtDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _debtTitleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _debtAmountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _debtNotesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            TextField(
              controller: _debtContactNameController,
              decoration: const InputDecoration(labelText: 'Contact Name'),
            ),
            TextField(
              controller: _debtContactPhoneController,
              decoration: const InputDecoration(labelText: 'Contact Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_debtTitleController.text.isNotEmpty && _debtAmountController.text.isNotEmpty) {
                final debt = Debt(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _debtTitleController.text,
                  amount: double.parse(_debtAmountController.text),
                  dueDate: DateTime.now().add(const Duration(days: 30)),
                  isPaid: false,
                  isLender: false,
                  notes: _debtNotesController.text,
                  contactName: _debtContactNameController.text,
                  contactPhone: _debtContactPhoneController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                try {
                  // Save to Firebase first
                  await _databaseService.addDebt(debt);
                  
                  // Then update local state
                  setState(() {
                    _debts.add(debt);
                  });
                  
                  // Notify parent widget
                  widget.onDebtAdded?.call(debt);
                  
                  // Clear controllers
                  _debtTitleController.clear();
                  _debtAmountController.clear();
                  _debtNotesController.clear();
                  _debtContactNameController.clear();
                  _debtContactPhoneController.clear();
                  
                  Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding debt: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSplitBillDialog() {
    _clearSplitBillControllers();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Split Bill'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _splitBillTitleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _splitBillAmountController,
                decoration: const InputDecoration(labelText: 'Total Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _splitBillNotesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_splitBillTitleController.text.isNotEmpty && _splitBillAmountController.text.isNotEmpty) {
                final totalAmount = double.parse(_splitBillAmountController.text);
                final splitBill = SplitBill(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _splitBillTitleController.text,
                  totalAmount: totalAmount,
                  yourShare: totalAmount / 3, // Assuming 3 participants for now
                  date: DateTime.now().add(const Duration(days: 7)),
                  participants: 3,
                  isPaid: false,
                  notes: _splitBillNotesController.text,
                  participantIds: ['user1', 'user2', 'user3'],
                  createdBy: 'currentUserId',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                _addSplitBill(splitBill);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showPayDebtDialog(Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay Debt'),
        content: Text('Are you sure you want to mark this debt as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedDebt = debt.copyWith(
                  isPaid: true,
                  updatedAt: DateTime.now(),
                );
                await _databaseService.updateDebt(updatedDebt);
                setState(() {
                  final index = _debts.indexWhere((d) => d.id == debt.id);
                  if (index != -1) {
                    _debts[index] = updatedDebt;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debt marked as paid')),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating debt: $e')),
                  );
                }
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _showPaySplitBillDialog(SplitBill splitBill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay Split Bill'),
        content: Text('Are you sure you want to mark this split bill as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedSplitBill = splitBill.copyWith(
                  isPaid: true,
                  updatedAt: DateTime.now(),
                );
                await _databaseService.updateSplitBill(updatedSplitBill);
                setState(() {
                  final index = _splitBills.indexWhere((s) => s.id == splitBill.id);
                  if (index != -1) {
                    _splitBills[index] = updatedSplitBill;
                  }
                });
                Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating split bill: $e')),
                  );
                }
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'Bills & Payments',
            ),
            Tab(
              icon: Icon(Icons.money_off),
              text: 'Debt',
            ),
            Tab(
              icon: Icon(Icons.group),
              text: 'Split Bill',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _BillsTab(),
          _DebtTab(
            debts: _debts,
            onDebtAdded: (debt) {
              setState(() {
                _debts.add(debt);
              });
            },
          ),
          _SplitBillTab(splitBills: _splitBills, onSplitBillAdded: _addSplitBill),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentTabIndex == 1) {
            // Add new debt
            _showAddDebtDialog();
          } else if (_currentTabIndex == 2) {
            // Add new split bill
            _showAddSplitBillDialog();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BillsTab extends StatelessWidget {
  const _BillsTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.search),
                text: 'Check Bills',
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                const _CheckBillsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckBillsTab extends StatefulWidget {
  const _CheckBillsTab();

  @override
  State<_CheckBillsTab> createState() => _CheckBillsTabState();
}

class _CheckBillsTabState extends State<_CheckBillsTab> {
  final _formKey = GlobalKey<FormState>();
  String _selectedUtility = 'Electricity';
  final _billNumberController = TextEditingController();
  bool _isLoading = false;
  bool? _isPaid;
  double? _amount;
  String? _dueDate;

  @override
  void dispose() {
    _billNumberController.dispose();
    super.dispose();
  }

  Future<void> _checkBill() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _isPaid = null;
        _amount = null;
        _dueDate = null;
      });

      try {
        // Simulate API call to check bill status
        await Future.delayed(const Duration(seconds: 1));
        
        // For demo purposes, we'll use a simple logic:
        // If bill number contains "paid", it's paid
        // If it contains "unpaid", it's unpaid
        // Otherwise, randomly set the status
        final billNumber = _billNumberController.text.toLowerCase();
        if (billNumber.contains('paid')) {
          _isPaid = true;
        } else if (billNumber.contains('unpaid')) {
          _isPaid = false;
          _amount = 500000; // Example amount
          _dueDate = DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0];
        } else {
          _isPaid = false;
          _amount = 750000; // Example amount
          _dueDate = DateTime.now().add(const Duration(days: 14)).toString().split(' ')[0];
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error checking bill: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _payBill() async {
    if (_amount == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call to process payment
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a transaction for the bill payment
      final now = DateTime.now();
      final transaction = Transaction(
        id: now.millisecondsSinceEpoch.toString(),
        description: '${_selectedUtility} Bill Payment',
        amount: _amount!,
        category: 'Bills',
        date: now,
        isExpense: true,
        walletId: 'default_wallet',
        notes: 'Bill Number: ${_billNumberController.text}',
        createdAt: now,
        updatedAt: now,
        userId: 'default_user',
      );

      // Add the transaction
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );
      transactionProvider.addTransaction(transaction);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bill paid successfully!')),
        );
        setState(() {
          _isPaid = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error paying bill: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getUtilityIcon(_selectedUtility),
                            color: _getUtilityColor(_selectedUtility),
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Check Bill Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Enter your bill details below to check the payment status and make a payment if needed.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedUtility,
                decoration: InputDecoration(
                  labelText: 'Utility Type',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(
                    _getUtilityIcon(_selectedUtility),
                    color: _getUtilityColor(_selectedUtility),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Electricity', child: Text('Electricity')),
                  DropdownMenuItem(value: 'Water', child: Text('Water')),
                  DropdownMenuItem(value: 'Internet', child: Text('Internet')),
                  DropdownMenuItem(value: 'Phone', child: Text('Phone')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedUtility = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _billNumberController,
                decoration: InputDecoration(
                  labelText: 'Bill Number',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a bill number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isLoading ? null : _checkBill,
                icon: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_isLoading ? 'Checking...' : 'Check Bill'),
              ),
              if (_isPaid != null) ...[
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isPaid! ? Icons.check_circle : Icons.error,
                              color: _isPaid! ? Colors.green : Colors.red,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Bill Status',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              _isPaid! ? Icons.check_circle : Icons.error,
                              color: _isPaid! ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPaid! ? 'Paid' : 'Unpaid',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _isPaid! ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        if (!_isPaid! && _amount != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Amount Due: Rp ${_amount!.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_dueDate != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Due Date: $_dueDate',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _isLoading ? null : _payBill,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.payment),
                            label: Text(_isLoading ? 'Processing...' : 'Pay Now'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getUtilityIcon(String utility) {
    switch (utility.toLowerCase()) {
      case 'electricity':
        return Icons.electric_bolt;
      case 'water':
        return Icons.water_drop;
      case 'internet':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.receipt;
    }
  }

  Color _getUtilityColor(String utility) {
    switch (utility.toLowerCase()) {
      case 'electricity':
        return Colors.amber;
      case 'water':
        return Colors.blue;
      case 'internet':
        return Colors.purple;
      case 'phone':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }
}

class _DebtTab extends StatefulWidget {
  final List<Debt> debts;
  final Function(Debt) onDebtAdded;
  
  const _DebtTab({
    required this.debts,
    required this.onDebtAdded,
  });

  @override
  State<_DebtTab> createState() => _DebtTabState();
}

class _DebtTabState extends State<_DebtTab> {
  late List<Debt> _debts;
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  // Add text controllers
  final TextEditingController _debtTitleController = TextEditingController();
  final TextEditingController _debtAmountController = TextEditingController();
  final TextEditingController _debtNotesController = TextEditingController();
  final TextEditingController _debtContactNameController = TextEditingController();
  final TextEditingController _debtContactPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _debts = widget.debts;
  }

  @override
  void dispose() {
    // Dispose of the controllers
    _debtTitleController.dispose();
    _debtAmountController.dispose();
    _debtNotesController.dispose();
    _debtContactNameController.dispose();
    _debtContactPhoneController.dispose();
    super.dispose();
  }

  void addDebt(Debt debt) async {
    try {
      // Save to Firebase first
      await _databaseService.addDebt(debt);
      
      // Then update local state
      setState(() {
        _debts.add(debt);
      });
      
      // Notify parent widget
      widget.onDebtAdded(debt);
      
      // Clear controllers
      _debtTitleController.clear();
      _debtAmountController.clear();
      _debtNotesController.clear();
      _debtContactNameController.clear();
      _debtContactPhoneController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding debt: $e')),
        );
      }
    }
  }

  void _showAddDebtDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _debtTitleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _debtAmountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _debtNotesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
            TextField(
              controller: _debtContactNameController,
              decoration: const InputDecoration(labelText: 'Contact Name'),
            ),
            TextField(
              controller: _debtContactPhoneController,
              decoration: const InputDecoration(labelText: 'Contact Phone'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_debtTitleController.text.isNotEmpty && _debtAmountController.text.isNotEmpty) {
                final debt = Debt(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _debtTitleController.text,
                  amount: double.parse(_debtAmountController.text),
                  dueDate: DateTime.now().add(const Duration(days: 30)),
                  isPaid: false,
                  isLender: false,
                  notes: _debtNotesController.text,
                  contactName: _debtContactNameController.text,
                  contactPhone: _debtContactPhoneController.text,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                try {
                  // Save to Firebase first
                  await _databaseService.addDebt(debt);
                  
                  // Then update local state
                  setState(() {
                    _debts.add(debt);
                  });
                  
                  // Notify parent widget
                  widget.onDebtAdded(debt);
                  
                  // Clear controllers
                  _debtTitleController.clear();
                  _debtAmountController.clear();
                  _debtNotesController.clear();
                  _debtContactNameController.clear();
                  _debtContactPhoneController.clear();
                  
                  Navigator.pop(context);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error adding debt: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showPayDebtDialog(Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay Debt'),
        content: Text('Are you sure you want to mark this debt as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedDebt = debt.copyWith(
                  isPaid: true,
                  updatedAt: DateTime.now(),
                );
                await _databaseService.updateDebt(updatedDebt);
                setState(() {
                  final index = _debts.indexWhere((d) => d.id == debt.id);
                  if (index != -1) {
                    _debts[index] = updatedDebt;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debt marked as paid')),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating debt: $e')),
                  );
                }
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _showMarkAsUnpaidDialog(BuildContext context, Debt debt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Unpaid'),
        content: const Text('Are you sure you want to mark this debt as unpaid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final updatedDebt = debt.copyWith(
                  isPaid: false,
                  updatedAt: DateTime.now(),
                );
                await _databaseService.updateDebt(updatedDebt);
                setState(() {
                  final index = _debts.indexWhere((d) => d.id == debt.id);
                  if (index != -1) {
                    _debts[index] = updatedDebt;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debt marked as unpaid')),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating debt: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.money_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No debts yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your debts will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                _showAddDebtDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Debt'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _debts.length,
      itemBuilder: (context, index) {
        final debt = _debts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: const Icon(
                        Icons.money_off,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            debt.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due: ${_formatDate(debt.dueDate)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: debt.isPaid
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        debt.isPaid ? 'Paid' : 'Unpaid',
                        style: TextStyle(
                          color: debt.isPaid ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${debt.amount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (!debt.isPaid)
                      FilledButton.icon(
                        onPressed: () {
                          _showPayDebtDialog(debt);
                        },
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Pay Now'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () {
                          _showMarkAsUnpaidDialog(context, debt);
                        },
                        icon: const Icon(Icons.undo, size: 18),
                        label: const Text('Mark as Unpaid'),
                      ),
                  ],
                ),
                if (debt.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            debt.notes,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SplitBillTab extends StatefulWidget {
  final List<SplitBill> splitBills;
  final Function(SplitBill) onSplitBillAdded;

  const _SplitBillTab({
    required this.splitBills,
    required this.onSplitBillAdded,
  });

  @override
  State<_SplitBillTab> createState() => _SplitBillTabState();
}

class _SplitBillTabState extends State<_SplitBillTab> {
  late List<SplitBill> _splitBills;
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  // Add text controllers
  final TextEditingController _splitBillTitleController = TextEditingController();
  final TextEditingController _splitBillAmountController = TextEditingController();
  final TextEditingController _splitBillNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _splitBills = widget.splitBills;
  }

  @override
  void dispose() {
    _splitBillTitleController.dispose();
    _splitBillAmountController.dispose();
    _splitBillNotesController.dispose();
    super.dispose();
  }

  void addSplitBill(SplitBill splitBill) {
    widget.onSplitBillAdded(splitBill);
  }

  @override
  Widget build(BuildContext context) {
    if (_splitBills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No split bills yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your split bills will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                _showAddSplitBillDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Split Bill'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _splitBills.length,
      itemBuilder: (context, index) {
        final splitBill = _splitBills[index];
        final yourShare = splitBill.yourShare;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(
                        Icons.group,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            splitBill.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due: ${_formatDate(splitBill.date)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: splitBill.isPaid
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        splitBill.isPaid ? 'Paid' : 'Pending',
                        style: TextStyle(
                          color: splitBill.isPaid ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${splitBill.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Your Share',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${splitBill.yourShare.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: splitBill.isPaid ? 1.0 : 0.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    splitBill.isPaid ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${splitBill.isPaid ? 'Fully Paid' : 'Payment Pending'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${splitBill.participants} participants',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (!splitBill.isPaid)
                      FilledButton.icon(
                        onPressed: () {
                          _showPaySplitBillDialog(splitBill);
                        },
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Pay Your Share'),
                      ),
                  ],
                ),
                if (splitBill.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            splitBill.notes,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddSplitBillDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Split Bill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _splitBillTitleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _splitBillAmountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _splitBillNotesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final totalAmount = double.parse(_splitBillAmountController.text);
              final splitBill = SplitBill(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: _splitBillTitleController.text,
                totalAmount: totalAmount,
                yourShare: totalAmount / 3, // Assuming 3 participants for now
                date: DateTime.now().add(const Duration(days: 7)),
                participants: 3,
                isPaid: false,
                notes: _splitBillNotesController.text,
                participantIds: ['user1', 'user2', 'user3'],
                createdBy: 'currentUserId',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              addSplitBill(splitBill);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showPaySplitBillDialog(SplitBill splitBill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pay Split Bill'),
        content: Text('Are you sure you want to mark this split bill as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final updatedSplitBill = splitBill.copyWith(
                  isPaid: true,
                  updatedAt: DateTime.now(),
                );
                await _databaseService.updateSplitBill(updatedSplitBill);
                setState(() {
                  final index = _splitBills.indexWhere((s) => s.id == splitBill.id);
                  if (index != -1) {
                    _splitBills[index] = updatedSplitBill;
                  }
                });
                Navigator.pop(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating split bill: $e')),
                  );
                }
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 