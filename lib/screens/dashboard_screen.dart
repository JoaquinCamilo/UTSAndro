import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/financial_provider.dart';
import '../models/transaction.dart';
import '../widgets/base_screen.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _selectedPeriod = 'Monthly';

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  void _handlePeriodChange(String? newPeriod) {
    if (newPeriod != null) {
      setState(() {
        _selectedPeriod = newPeriod;
      });
    }
  }

  Map<String, double> _calculateCategoryTotals(List<Transaction> transactions) {
    final categoryTotals = <String, double>{};
    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categoryTotals[transaction.category] = (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return categoryTotals;
  }

  List<FlSpot> _calculatePeriodTotals(List<Transaction> transactions, bool isExpense) {
    final monthlyTotals = <int, double>{};
    final now = DateTime.now();
    DateTime startDate;
    int numPoints;
    
    switch (_selectedPeriod) {
      case 'Weekly':
        startDate = now.subtract(const Duration(days: 7));
        numPoints = 7;
        break;
      case 'Monthly':
        startDate = DateTime(now.year, now.month - 6, 1);
        numPoints = 6;
        break;
      case 'Yearly':
        startDate = DateTime(now.year - 1, now.month, 1);
        numPoints = 12;
        break;
      default:
        startDate = DateTime(now.year, now.month - 6, 1);
        numPoints = 6;
    }

    for (var transaction in transactions) {
      if (transaction.isExpense == isExpense && transaction.date.isAfter(startDate)) {
        final key = _selectedPeriod == 'Weekly' 
            ? transaction.date.difference(startDate).inDays
            : _selectedPeriod == 'Monthly'
                ? transaction.date.year * 12 + transaction.date.month
                : transaction.date.year * 12 + transaction.date.month;
        monthlyTotals[key] = (monthlyTotals[key] ?? 0) + transaction.amount;
      }
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < numPoints; i++) {
      final date = _selectedPeriod == 'Weekly'
          ? now.subtract(Duration(days: numPoints - 1 - i))
          : _selectedPeriod == 'Monthly'
              ? DateTime(now.year, now.month - (numPoints - 1 - i), 1)
              : DateTime(now.year - 1 + (i ~/ 12), now.month + (i % 12), 1);
      
      final key = _selectedPeriod == 'Weekly'
          ? i
          : date.year * 12 + date.month;
      
      spots.add(FlSpot(i.toDouble(), monthlyTotals[key] ?? 0));
    }
    return spots;
  }

  Widget _buildExpensePieChart(List<Transaction> transactions) {
    final categoryTotals = _calculateCategoryTotals(transactions);
    final totalExpenses = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    if (categoryTotals.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Tidak ada data pengeluaran'),
          ),
        ),
      );
    }

    final sections = categoryTotals.entries.map((entry) {
      final percentage = (entry.value / totalExpenses) * 100;
      return PieChartSectionData(
        color: Colors.primaries[categoryTotals.keys.toList().indexOf(entry.key) % Colors.primaries.length],
        value: entry.value,
        title: '${entry.key}\n${percentage.toStringAsFixed(1)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Pengeluaran',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseLineChart(List<Transaction> transactions) {
    final incomeSpots = _calculatePeriodTotals(transactions, false);
    final expenseSpots = _calculatePeriodTotals(transactions, true);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tren Pemasukan & Pengeluaran',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  items: ['Weekly', 'Monthly', 'Yearly'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: _handlePeriodChange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final now = DateTime.now();
                          final date = _selectedPeriod == 'Weekly'
                              ? now.subtract(Duration(days: (5 - value).toInt()))
                              : _selectedPeriod == 'Monthly'
                                  ? DateTime(now.year, now.month - (5 - value.toInt()), 1)
                                  : DateTime(now.year - 1 + (value.toInt() ~/ 12), now.month + (value.toInt() % 12), 1);
                          
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _selectedPeriod == 'Weekly'
                                  ? DateFormat('E').format(date)
                                  : _selectedPeriod == 'Monthly'
                                      ? DateFormat('MMM').format(date)
                                      : DateFormat('MMM yy').format(date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: incomeSpots,
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
                      spots: expenseSpots,
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
                _buildChartLegend('Pemasukan', Colors.green),
                const SizedBox(width: 24),
                _buildChartLegend('Pengeluaran', Colors.red),
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

  Widget _buildBalanceCard(BuildContext context, double balance) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[900]!,
              Colors.black,
              Colors.black87,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saldo Total',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.green[400],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Pemasukan',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(context.read<FinancialProvider>().totalIncome),
                              style: TextStyle(
                                color: Colors.green[400],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Colors.red[400],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Pengeluaran',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatCurrency(context.read<FinancialProvider>().totalExpenses),
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Dasbor',
      currentIndex: 0,
      child: Consumer<FinancialProvider>(
        builder: (context, financialProvider, child) {
          final transactions = financialProvider.transactions;
          final monthlySummary = _calculateMonthlySummary(transactions);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildBalanceCard(context, financialProvider.totalBalance),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMonthlySummaryProgress(monthlySummary),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildIncomeExpenseLineChart(transactions),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildExpensePieChart(transactions),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildRecentTransactions(transactions),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMonthlySummaryNotification(BuildContext context) {
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1);
    final transactions = context.read<FinancialProvider>().transactions;
    
    final lastMonthTransactions = transactions.where((transaction) {
      return transaction.date.year == lastMonth.year &&
          transaction.date.month == lastMonth.month;
    }).toList();

    double totalSpent = 0;
    for (var transaction in lastMonthTransactions) {
      if (transaction.isExpense) {
        totalSpent += transaction.amount;
      }
    }

    final monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ringkasan Bulan Lalu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bulan: ${monthNames[lastMonth.month - 1]} ${lastMonth.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total Pengeluaran:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Rp ${totalSpent.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jumlah Transaksi: ${lastMonthTransactions.length}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryProgress(Map<String, double> monthlySummary) {
    if (monthlySummary.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text('Tidak ada data transaksi bulan ini'),
          ),
        ),
      );
    }

    final totalIncome = monthlySummary['Pemasukan'] ?? 0;
    final totalExpenses = monthlySummary['Pengeluaran'] ?? 0;
    final total = totalIncome + totalExpenses;
    final incomePercentage = total > 0 ? ((totalIncome / total) * 100).toDouble() : 0.0;
    final expensePercentage = total > 0 ? ((totalExpenses / total) * 100).toDouble() : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Bulan Ini',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildProgressItem(
                  'Pemasukan',
                  totalIncome,
                  Colors.green,
                  incomePercentage,
                ),
                const SizedBox(height: 16),
                _buildProgressItem(
                  'Pengeluaran',
                  totalExpenses,
                  Colors.red,
                  expensePercentage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, double amount, Color color, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Rp ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(List<Transaction> transactions) {
    final recentTransactions = transactions.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Transaksi Terakhir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (recentTransactions.isEmpty)
              const Center(
                child: Text('Tidak ada transaksi'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: transaction.isExpense
                          ? Colors.red.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                      child: Icon(
                        transaction.isExpense
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: transaction.isExpense ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(transaction.description),
                    subtitle: Text(
                      '${transaction.category} • ${DateFormat('dd MMM yyyy').format(transaction.date)}',
                    ),
                    trailing: Text(
                      _formatCurrency(transaction.amount),
                      style: TextStyle(
                        color: transaction.isExpense ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateMonthlySummary(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthlyTransactions = transactions.where((transaction) {
      return transaction.date.year == now.year &&
          transaction.date.month == now.month;
    }).toList();

    double totalIncome = 0;
    double totalExpenses = 0;

    for (var transaction in monthlyTransactions) {
      if (transaction.isExpense) {
        totalExpenses += transaction.amount;
      } else {
        totalIncome += transaction.amount;
      }
    }

    return {
      'Pemasukan': totalIncome,
      'Pengeluaran': totalExpenses,
    };
  }
} 