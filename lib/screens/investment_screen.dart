import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _goalNameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _deadlineController = TextEditingController();
  String? _selectedGoalType;
  bool _isLoading = false;
  DateTime? _selectedDate;

  final List<Map<String, dynamic>> _goalTypes = [
    {
      'name': 'Emergency Fund',
      'icon': Icons.emergency,
      'color': Colors.red,
      'description': 'Save for unexpected expenses',
    },
    {
      'name': 'Vacation',
      'icon': Icons.flight,
      'color': Colors.blue,
      'description': 'Save for your dream vacation',
    },
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': Colors.green,
      'description': 'Save for education expenses',
    },
    {
      'name': 'Home',
      'icon': Icons.home,
      'color': Colors.orange,
      'description': 'Save for a down payment',
    },
    {
      'name': 'Retirement',
      'icon': Icons.elderly,
      'color': Colors.purple,
      'description': 'Save for retirement',
    },
    {
      'name': 'Custom',
      'icon': Icons.add_circle,
      'color': Colors.grey,
      'description': 'Create a custom savings goal',
    },
  ];

  final List<Map<String, dynamic>> _sampleGoals = [
    {
      'name': 'Emergency Fund',
      'icon': Icons.emergency,
      'color': Colors.red,
      'currentAmount': 5000000,
      'targetAmount': 10000000,
      'deadline': DateTime.now().add(const Duration(days: 365)),
      'description': 'Save for unexpected expenses',
    },
    {
      'name': 'Vacation to Bali',
      'icon': Icons.flight,
      'color': Colors.blue,
      'currentAmount': 2000000,
      'targetAmount': 5000000,
      'deadline': DateTime.now().add(const Duration(days: 180)),
      'description': 'Save for a week in Bali',
    },
    {
      'name': 'New Laptop',
      'icon': Icons.laptop,
      'color': Colors.green,
      'currentAmount': 5000000,
      'targetAmount': 15000000,
      'deadline': DateTime.now().add(const Duration(days: 90)),
      'description': 'Save for a new laptop',
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _goalNameController.dispose();
    _targetAmountController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _deadlineController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _addToGoal(String goalName, double amount) async {
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Find the goal in the sample goals
      final goalIndex = _sampleGoals.indexWhere((goal) => goal['name'] == goalName);
      
      if (goalIndex != -1) {
        // Update the goal's current amount
        setState(() {
          _sampleGoals[goalIndex]['currentAmount'] += amount;
        });
        
        // Add a transaction for the goal contribution
        final transaction = Transaction(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          amount: amount,
          description: 'Contribution to ${goalName}',
          date: DateTime.now(),
          isExpense: true,
          category: 'Goals',
          walletId: 'default_wallet',
          notes: 'Contribution to ${goalName} goal',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 'default_user',
        );
        
        Provider.of<TransactionProvider>(context, listen: false).addTransaction(transaction);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added Rp ${amount.toStringAsFixed(0)} to $goalName'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Goal not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _amountController.clear();
        });
      }
    }
  }

  void _showAddToGoalDialog(String goalName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add to $goalName'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount (Rp)',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (double.parse(value) <= 0) {
                return 'Amount must be greater than 0';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final amount = double.parse(_amountController.text);
                _addToGoal(goalName, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCreateGoalDialog() {
    _goalNameController.clear();
    _targetAmountController.clear();
    _deadlineController.clear();
    _selectedDate = null;
    _selectedGoalType = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Goal'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedGoalType,
                  decoration: const InputDecoration(
                    labelText: 'Goal Type',
                  ),
                  items: _goalTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['name'],
                      child: Row(
                        children: [
                          Icon(type['icon'], color: type['color']),
                          const SizedBox(width: 8),
                          Text(type['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGoalType = value;
                      if (value != 'Custom') {
                        _goalNameController.text = value!;
                      } else {
                        _goalNameController.clear();
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a goal type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedGoalType == 'Custom')
                  TextFormField(
                    controller: _goalNameController,
                    decoration: const InputDecoration(
                      labelText: 'Goal Name',
                    ),
                    validator: (value) {
                      if (_selectedGoalType == 'Custom' && (value == null || value.isEmpty)) {
                        return 'Please enter a goal name';
                      }
                      return null;
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount (Rp)',
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deadlineController,
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a deadline';
                    }
                    return null;
                  },
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
              if (_formKey.currentState!.validate()) {
                final goalType = _selectedGoalType!;
                final goalName = goalType == 'Custom' ? _goalNameController.text : goalType;
                final targetAmount = double.parse(_targetAmountController.text);
                final deadline = _selectedDate ?? DateTime.now().add(const Duration(days: 365));
                
                // Find the icon and color for the selected goal type
                final goalTypeData = _goalTypes.firstWhere(
                  (type) => type['name'] == goalType,
                  orElse: () => {'icon': Icons.add_circle, 'color': Colors.grey},
                );
                
                // Add the new goal to the sample goals
                setState(() {
                  _sampleGoals.add({
                    'name': goalName,
                    'icon': goalTypeData['icon'],
                    'color': goalTypeData['color'],
                    'currentAmount': 0,
                    'targetAmount': targetAmount,
                    'deadline': deadline,
                    'description': goalTypeData['description'],
                  });
                });
                
                Navigator.pop(context);
                
                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Goal "$goalName" created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGoalDialog,
          ),
        ],
      ),
      body: _sampleGoals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No goals yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first financial goal',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _showCreateGoalDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Goal'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sampleGoals.length,
              itemBuilder: (context, index) {
                final goal = _sampleGoals[index];
                final progress = goal['currentAmount'] / goal['targetAmount'];
                final daysLeft = goal['deadline'].difference(DateTime.now()).inDays;
                final isCompleted = progress >= 1.0;
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: goal['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                goal['icon'],
                                color: goal['color'],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['name'],
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    goal['description'],
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? Colors.green : goal['color'],
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rp ${goal['currentAmount'].toStringAsFixed(0)} / Rp ${goal['targetAmount'].toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: isCompleted ? Colors.green : goal['color'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  daysLeft > 0
                                      ? '$daysLeft days left'
                                      : 'Deadline passed',
                                  style: TextStyle(
                                    color: daysLeft > 0 ? Colors.grey[600] : Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            if (!isCompleted)
                              FilledButton(
                                onPressed: () => _showAddToGoalDialog(goal['name']),
                                child: const Text('Add to Goal'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
} 