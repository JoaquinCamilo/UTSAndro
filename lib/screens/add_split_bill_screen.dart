import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/split_bill.dart';
import '../providers/split_bill_provider.dart';
import '../services/realtime_database_service.dart';

class AddSplitBillScreen extends StatefulWidget {
  const AddSplitBillScreen({super.key});

  @override
  State<AddSplitBillScreen> createState() => _AddSplitBillScreenState();
}

class _AddSplitBillScreenState extends State<AddSplitBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  int _participants = 2;
  bool _isPaid = false;
  final List<String> _participantIds = [];
  final RealtimeDatabaseService _databaseService = RealtimeDatabaseService();

  @override
  void dispose() {
    _titleController.dispose();
    _totalAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _saveSplitBill() async {
    if (_formKey.currentState!.validate()) {
      final totalAmount = double.parse(_totalAmountController.text);
      final yourShare = totalAmount / _participants;

      final splitBill = SplitBill(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        totalAmount: totalAmount,
        yourShare: yourShare,
        date: _date,
        participants: _participants,
        isPaid: _isPaid,
        notes: _notesController.text,
        participantIds: _participantIds,
        createdBy: _databaseService.currentUserId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        await context.read<SplitBillProvider>().addSplitBill(splitBill);
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan tagihan bersama: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Tagihan Bersama'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSplitBill,
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
              controller: _totalAmountController,
              decoration: const InputDecoration(
                labelText: 'Total Jumlah',
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
              title: const Text('Tanggal'),
              subtitle: Text(
                '${_date.day}/${_date.month}/${_date.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Jumlah Peserta'),
              subtitle: Text('$_participants orang'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _participants > 2
                        ? () {
                            setState(() {
                              _participants--;
                            });
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _participants++;
                      });
                    },
                  ),
                ],
              ),
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