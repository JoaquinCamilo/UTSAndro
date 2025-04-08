import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isExpense = true;
  bool _isRecurring = false;
  String _recurringFrequency = '';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transaction Type Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jenis Transaksi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Pengeluaran'),
                            value: true,
                            groupValue: _isExpense,
                            onChanged: (value) {
                              setState(() {
                                _isExpense = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Pemasukan'),
                            value: false,
                            groupValue: _isExpense,
                            onChanged: (value) {
                              setState(() {
                                _isExpense = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Amount Field
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jumlah tidak boleh kosong';
                }
                if (double.tryParse(value) == null) {
                  return 'Masukkan jumlah yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category Field
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kategori tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Recurring Transaction
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Transaksi Berulang',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Aktifkan transaksi berulang'),
                      value: _isRecurring,
                      onChanged: (value) {
                        setState(() {
                          _isRecurring = value;
                        });
                      },
                    ),
                    if (_isRecurring) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            _recurringFrequency = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Frekuensi (misal: Bulanan)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Simpan Transaksi'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'default_user_id', // TODO: Replace with actual user ID from auth
        amount: double.parse(_amountController.text),
        isExpense: _isExpense,
        category: _categoryController.text,
        description: _descriptionController.text,
        date: DateTime.now(),
        walletId: 'default_wallet_id', // TODO: Replace with actual wallet ID
        notes: _descriptionController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      Provider.of<FinancialProvider>(context, listen: false)
          .addTransaction(transaction);

      Navigator.pop(context);
    }
  }
} 