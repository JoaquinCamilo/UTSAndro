import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bill_provider.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to add bill screen
            },
          ),
        ],
      ),
      body: Consumer<BillProvider>(
        builder: (context, billProvider, child) {
          if (billProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (billProvider.error != null) {
            return Center(child: Text(billProvider.error!));
          }

          final bills = billProvider.bills;
          if (bills.isEmpty) {
            return const Center(child: Text('No bills yet'));
          }

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: bill.isPaid 
                        ? Colors.green.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    child: Icon(
                      bill.isPaid ? Icons.check : Icons.pending,
                      color: bill.isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(bill.title),
                  subtitle: Text(bill.notes),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp ${bill.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bill.isPaid ? 'Paid' : 'Unpaid',
                        style: TextStyle(
                          color: bill.isPaid ? Colors.green : Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // TODO: Navigate to bill details screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 