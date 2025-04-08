import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';

class DebtScreen extends StatelessWidget {
  const DebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Hutang',
      currentIndex: 4,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAddDebtButton(context),
            const SizedBox(height: 24),
            _buildDebtsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddDebtButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement add debt functionality
      },
      icon: const Icon(Icons.add),
      label: const Text('Tambah Hutang'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildDebtsList() {
    // TODO: Replace with actual debts from provider
    final dummyDebts = [
      {
        'title': 'Pinjaman Bank',
        'amount': 10000000,
        'dueDate': '2024-06-15',
        'isPaid': false,
        'isLender': false,
      },
      {
        'title': 'Pinjaman Teman',
        'amount': 500000,
        'dueDate': '2024-04-01',
        'isPaid': true,
        'isLender': true,
      },
    ];

    if (dummyDebts.isEmpty) {
      return const Center(
        child: Text('Belum ada hutang'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dummyDebts.length,
      itemBuilder: (context, index) {
        final debt = dummyDebts[index];
        final isPaid = debt['isPaid'] as bool;
        final isLender = debt['isLender'] as bool;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isPaid ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              child: Icon(
                isPaid ? Icons.check : Icons.warning,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),
            title: Text(debt['title'] as String),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jatuh Tempo: ${debt['dueDate']}'),
                Text(
                  isLender ? 'Anda meminjamkan' : 'Anda meminjam',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rp ${debt['amount']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isPaid ? 'Lunas' : 'Belum Lunas',
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () {
              // TODO: Show debt details
            },
          ),
        );
      },
    );
  }
} 