import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeFilter = 'All';
  final List<String> _timeFilters = ['All', 'Weekly', 'Monthly', 'Yearly'];
  String _chartType = 'Bar';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _timeFilters.length, vsync: this);
    _selectedDate = DateTime.now();
    
    // Load transactions when the screen is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Add method to calculate chart data
  List<BarChartGroupData> _getBarChartData(List<Transaction> transactions) {
    final now = DateTime.now();
    final Map<int, double> incomeData = {};
    final Map<int, double> expenseData = {};
    
    // Initialize data points based on selected time filter
    int numPoints;
    DateTime startDate;
    
    switch (_selectedTimeFilter) {
      case 'Weekly':
        numPoints = 7;
        startDate = now.subtract(const Duration(days: 6));
        for (int i = 0; i < numPoints; i++) {
          final date = startDate.add(Duration(days: i));
          incomeData[date.day] = 0;
          expenseData[date.day] = 0;
        }
        break;
      case 'Monthly':
        numPoints = 30;
        startDate = DateTime(now.year, now.month, 1);
        for (int i = 0; i < numPoints; i++) {
          final date = startDate.add(Duration(days: i));
          if (date.month == now.month) {
            incomeData[date.day] = 0;
            expenseData[date.day] = 0;
          }
        }
        break;
      case 'Yearly':
        numPoints = 12;
        startDate = DateTime(now.year, 1, 1);
        for (int i = 0; i < numPoints; i++) {
          final date = DateTime(now.year, i + 1, 1);
          incomeData[date.month] = 0;
          expenseData[date.month] = 0;
        }
        break;
      default: // All
        numPoints = 12;
        startDate = now.subtract(const Duration(days: 365));
        for (int i = 0; i < numPoints; i++) {
          final date = startDate.add(Duration(days: i * 30));
          final key = date.year * 100 + date.month;
          incomeData[key] = 0;
          expenseData[key] = 0;
        }
    }
    
    // Fill data points with transaction amounts
    for (var transaction in transactions) {
      int key;
      if (_selectedTimeFilter == 'Weekly') {
        key = transaction.date.day;
      } else if (_selectedTimeFilter == 'Monthly') {
        key = transaction.date.day;
      } else if (_selectedTimeFilter == 'Yearly') {
        key = transaction.date.month;
      } else {
        key = transaction.date.year * 100 + transaction.date.month;
      }
      
      if (transaction.isExpense) {
        expenseData[key] = (expenseData[key] ?? 0) + transaction.amount;
      } else {
        incomeData[key] = (incomeData[key] ?? 0) + transaction.amount;
      }
    }
    
    // Create bar chart groups
    final List<BarChartGroupData> barGroups = [];
    final keys = incomeData.keys.toList()..sort();
    
    for (int i = 0; i < keys.length; i++) {
      final key = keys[i];
      final income = incomeData[key] ?? 0;
      final expense = expenseData[key] ?? 0;
      
      if (income > 0 || expense > 0) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: income,
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: expense,
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        );
      }
    }
    
    return barGroups;
  }

  // Add method to get x-axis labels
  List<String> _getXAxisLabels() {
    final now = DateTime.now();
    final List<String> labels = [];
    
    switch (_selectedTimeFilter) {
      case 'Weekly':
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: 6 - i));
          labels.add(DateFormat('E').format(date));
        }
        break;
      case 'Monthly':
        for (int i = 1; i <= 31; i++) {
          if (i % 5 == 0) {
            labels.add(i.toString());
          } else {
            labels.add('');
          }
        }
        break;
      case 'Yearly':
        for (int i = 1; i <= 12; i++) {
          labels.add(DateFormat('MMM').format(DateTime(now.year, i, 1)));
        }
        break;
      default: // All
        for (int i = 0; i < 12; i++) {
          final date = now.subtract(Duration(days: 365 - i * 30));
          labels.add(DateFormat('MMM yy').format(date));
        }
    }
    
    return labels;
  }

  // Add method to build the chart
  Widget _buildTransactionChart(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    final barGroups = _getBarChartData(transactions);
    final xAxisLabels = _getXAxisLabels();
    
    if (barGroups.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _chartType,
                  items: ['Bar', 'Line'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _chartType = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _chartType == 'Bar'
                  ? BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: barGroups.fold<double>(
                          0,
                          (max, group) => group.barRods.fold<double>(
                            0,
                            (sum, rod) => sum + rod.toY,
                          ) > max
                              ? group.barRods.fold<double>(
                                  0,
                                  (sum, rod) => sum + rod.toY,
                                )
                              : max,
                        ) * 1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                'Income: ${_formatCurrency(rod.toY)}\n'
                                'Expense: ${_formatCurrency(group.barRods[1].toY)}',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < xAxisLabels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      xAxisLabels[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: barGroups,
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  'Value: ${_formatCurrency(spot.y)}',
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < xAxisLabels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      xAxisLabels[value.toInt()],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: barGroups.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value.barRods[0].toY,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.green,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.green.withOpacity(0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: barGroups.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value.barRods[1].toY,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.red,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.red.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildChartLegend('Income', Colors.green),
                const SizedBox(width: 24),
                _buildChartLegend('Expense', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  void _showAddTransactionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String description = '';
    String category = '';
    double amount = 0;
    bool isExpense = true;
    DateTime? dueDate;
    final dueDateController = TextEditingController();

    Future<void> _selectDueDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dueDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      );
      if (picked != null && picked != dueDate) {
        dueDate = picked;
        dueDateController.text = DateFormat('MMM d, yyyy').format(picked);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a category';
                      }
                      return null;
                    },
                    onSaved: (value) => category = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Amount (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => amount = double.parse(value ?? '0'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Due Date (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDueDate(context),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Transaction Type:'),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Expense'),
                            icon: Icon(Icons.remove),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Income'),
                            icon: Icon(Icons.add),
                          ),
                        ],
                        selected: {isExpense},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            isExpense = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final now = DateTime.now();
                  final transaction = Transaction(
                    id: now.millisecondsSinceEpoch.toString(),
                    description: description,
                    amount: amount,
                    category: category,
                    date: now,
                    isExpense: isExpense,
                    walletId: 'default_wallet',
                    notes: description,
                    createdAt: now,
                    updatedAt: now,
                    userId: 'default_user',
                    dueDate: dueDate,
                  );
                  final transactionProvider = Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  );
                  transactionProvider.addTransaction(transaction);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTransactionDialog(BuildContext context, Transaction transaction) {
    final formKey = GlobalKey<FormState>();
    String description = transaction.description;
    String category = transaction.category;
    double amount = transaction.amount;
    bool isExpense = transaction.isExpense;
    DateTime? dueDate = transaction.dueDate;
    final dueDateController = TextEditingController(
      text: dueDate != null ? DateFormat('MMM d, yyyy').format(dueDate) : '',
    );

    Future<void> _selectDueDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dueDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 3650)),
      );
      if (picked != null && picked != dueDate) {
        dueDate = picked;
        dueDateController.text = DateFormat('MMM d, yyyy').format(picked);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Transaction'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                    onSaved: (value) => description = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a category';
                      }
                      return null;
                    },
                    onSaved: (value) => category = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: amount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Amount (Rp)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => amount = double.parse(value ?? '0'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: dueDateController,
                    decoration: const InputDecoration(
                      labelText: 'Due Date (Optional)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _selectDueDate(context),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Transaction Type:'),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment<bool>(
                            value: true,
                            label: Text('Expense'),
                            icon: Icon(Icons.remove),
                          ),
                          ButtonSegment<bool>(
                            value: false,
                            label: Text('Income'),
                            icon: Icon(Icons.add),
                          ),
                        ],
                        selected: {isExpense},
                        onSelectionChanged: (Set<bool> newSelection) {
                          setState(() {
                            isExpense = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final now = DateTime.now();
                  final updatedTransaction = transaction.copyWith(
                    description: description,
                    amount: amount,
                    category: category,
                    isExpense: isExpense,
                    updatedAt: now,
                    dueDate: dueDate,
                  );
                  final transactionProvider = Provider.of<TransactionProvider>(
                    context,
                    listen: false,
                  );
                  transactionProvider.updateTransaction(updatedTransaction);
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final transactionProvider = Provider.of<TransactionProvider>(
                context,
                listen: false,
              );
              transactionProvider.deleteTransaction(transaction.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    final now = DateTime.now();
    
    // First filter by selected date if any
    if (_selectedDate != null) {
      transactions = transactions.where((t) {
        return t.date.year == _selectedDate!.year &&
               t.date.month == _selectedDate!.month &&
               t.date.day == _selectedDate!.day;
      }).toList();
    }
    
    // Then apply time filter
    switch (_selectedTimeFilter) {
      case 'Weekly':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return transactions.where((t) => t.date.isAfter(startOfWeekDay)).toList();
      
      case 'Monthly':
        final startOfMonth = DateTime(now.year, now.month, 1);
        return transactions.where((t) => t.date.isAfter(startOfMonth)).toList();
      
      case 'Yearly':
        final startOfYear = DateTime(now.year, 1, 1);
        return transactions.where((t) => t.date.isAfter(startOfYear)).toList();
      
      default:
        return transactions;
    }
  }

  String _getTimeFilterTitle() {
    switch (_selectedTimeFilter) {
      case 'Weekly':
        return 'This Week';
      case 'Monthly':
        return 'This Month';
      case 'Yearly':
        return 'This Year';
      default:
        return 'All Time';
    }
  }

  double _calculateTotal(List<Transaction> transactions) {
    return transactions.fold(0, (sum, t) => sum + (t.isExpense ? -t.amount : t.amount));
  }

  void _selectDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    ).then((picked) {
      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          // Add date picker button
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
          // Add filter button
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (String value) {
              setState(() {
                _selectedTimeFilter = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _timeFilters.map((String filter) {
                return PopupMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add selected date display
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selected Date: ${DateFormat('MMMM d, yyyy').format(_selectedDate!)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<TransactionProvider>(
                    builder: (context, provider, child) {
                      final filteredTransactions = _filterTransactions(provider.transactions);
                      final totalIncome = filteredTransactions
                          .where((t) => !t.isExpense)
                          .fold(0.0, (sum, t) => sum + t.amount);
                      final totalExpense = filteredTransactions
                          .where((t) => t.isExpense)
                          .fold(0.0, (sum, t) => sum + t.amount);
                      
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Income',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                'Rp ${totalIncome.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Expense',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                'Rp ${totalExpense.toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Balance',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              Text(
                                'Rp ${(totalIncome - totalExpense).toStringAsFixed(0)}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: (totalIncome - totalExpense) >= 0 ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          // Existing transaction list
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, transactionProvider, child) {
                if (transactionProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (transactionProvider.error != null) {
                  return Center(child: Text('Error: ${transactionProvider.error}'));
                }

                final allTransactions = transactionProvider.transactions;
                if (allTransactions.isEmpty) {
                  return const Center(child: Text('No transactions found'));
                }

                final filteredTransactions = _filterTransactions(allTransactions);
                
                if (filteredTransactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions for $_selectedTimeFilter',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a new transaction to get started',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                // Group transactions by date
                final groupedTransactions = <DateTime, List<Transaction>>{};
                for (final transaction in filteredTransactions) {
                  final date = DateTime(
                    transaction.date.year,
                    transaction.date.month,
                    transaction.date.day,
                  );
                  if (!groupedTransactions.containsKey(date)) {
                    groupedTransactions[date] = [];
                  }
                  groupedTransactions[date]!.add(transaction);
                }

                // Sort dates in descending order (newest first)
                final sortedDates = groupedTransactions.keys.toList()
                  ..sort((a, b) => b.compareTo(a));

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getTimeFilterTitle(),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Balance: Rp ${_calculateTotal(filteredTransactions).toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _calculateTotal(filteredTransactions) >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Add the chart here
                    _buildTransactionChart(filteredTransactions),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: sortedDates.length,
                        itemBuilder: (context, index) {
                          final date = sortedDates[index];
                          final transactions = groupedTransactions[date]!;
                          final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
                          final formattedDate = dateFormat.format(date);
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'Rp ${_calculateTotal(transactions).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _calculateTotal(transactions) >= 0 ? Colors.green : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...transactions.map((transaction) => Card(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: transaction.isExpense ? Colors.red : Colors.green,
                                    child: Icon(
                                      transaction.isExpense ? Icons.remove : Icons.add,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(transaction.description),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(transaction.category),
                                      if (transaction.dueDate != null)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 12,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Due: ${DateFormat('MMM d, yyyy').format(transaction.dueDate!)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Rp ${transaction.amount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: transaction.isExpense ? Colors.red : Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )).toList(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
} 