import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bill.dart';
import '../providers/bill_provider.dart';

class AddBillScreen extends StatefulWidget {
  const AddBillScreen({super.key});

  @override
  State<AddBillScreen> createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _dueDate = DateTime.now();
  bool _isPaid = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _saveBill() async {
    if (_formKey.currentState!.validate()) {
      final bill = Bill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        dueDate: _dueDate,
        isPaid: _isPaid,
        notes: _notesController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await context.read<BillProvider>().addBill(bill);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan tagihan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tagihan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveBill,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
                  return 'Jumlah harus diisi';
                }
                if (double.tryParse(value) == null) {
                  return 'Jumlah harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Tanggal Jatuh Tempo'),
              subtitle: Text(
                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sudah Dibayar'),
              value: _isPaid,
              onChanged: (value) {
                setState(() {
                  _isPaid = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
} 