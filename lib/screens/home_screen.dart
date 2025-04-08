import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/bill_provider.dart';
import '../models/transaction.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          if (transactionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (transactionProvider.error != null) {
            return Center(child: Text('Error: ${transactionProvider.error}'));
          }

          final transactions = transactionProvider.transactions;
          
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBalanceCard(context, transactionProvider),
                const SizedBox(height: 16),
                _buildTransactionHistory(context, transactions),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, TransactionProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF666666), Color(0xFF444444)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFFFFD700),
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Balance',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Rp ${provider.totalBalance.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      'Income',
                      provider.totalIncome,
                      const Color(0xFFFFD700),
                      Icons.arrow_upward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBalanceItem(
                      context,
                      'Expenses',
                      provider.totalExpenses,
                      Colors.red,
                      Icons.arrow_downward,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem(
    BuildContext context,
    String label,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              'Rp ${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionHistory(BuildContext context, List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No transactions yet'),
        ),
      );
    }

    // Group transactions by date
    final groupedTransactions = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      final date = transaction.date.toString().split(' ')[0];
      if (!groupedTransactions.containsKey(date)) {
        groupedTransactions[date] = [];
      }
      groupedTransactions[date]!.add(transaction);
    }

    // Sort dates in descending order
    final sortedDates = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(
                Icons.history,
                color: Color(0xFF666666),
              ),
              const SizedBox(width: 8),
              Text(
                'Transaction History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF666666),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            final date = sortedDates[index];
            final dateTransactions = groupedTransactions[date]!;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    _formatDate(date),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...dateTransactions.map((transaction) => _buildTransactionItem(context, transaction)),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return date;
    
    final year = parts[0];
    final month = parts[1];
    final day = parts[2];
    
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final monthName = months[int.parse(month) - 1];
    return '$day $monthName $year';
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isExpense = transaction.isExpense;
    final icon = _getTransactionIcon(transaction.category);
    final color = isExpense ? Colors.red : const Color(0xFFFFD700);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF666666).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: isExpense 
                ? Colors.red.withOpacity(0.1) 
                : const Color(0xFFFFD700).withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          title: Text(
            transaction.description,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF666666).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.category,
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (transaction.notes != null && transaction.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    transaction.notes!,
                    style: TextStyle(
                      color: const Color(0xFF666666).withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
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
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatTime(transaction.date),
                style: TextStyle(
                  color: const Color(0xFF666666).withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'bills':
        return Icons.receipt_long;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.medical_services;
      case 'education':
        return Icons.school;
      case 'income':
        return Icons.work;
      default:
        return Icons.category;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
} 