import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _goals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final goals = await _firestoreService.getGoals();
      setState(() {
        _goals = goals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load goals: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addToGoal(String goalId, double amount) async {
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
      await _firestoreService.addContributionToGoal(
        goalId: goalId,
        amount: amount,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contribution added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      _loadGoals();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add contribution: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createGoal() async {
    final nameController = TextEditingController();
    final targetAmountController = TextEditingController();
    final deadlineController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Goal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  hintText: 'e.g., New Car, Vacation',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: targetAmountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  hintText: 'e.g., 5000',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    selectedDate = date;
                    deadlineController.text = '${date.day}/${date.month}/${date.year}';
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Deadline',
                    hintText: 'Select a date',
                  ),
                  child: Text(
                    deadlineController.text.isEmpty
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : deadlineController.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a goal name'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final targetAmount = double.tryParse(targetAmountController.text);
              if (targetAmount == null || targetAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid target amount'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              Navigator.pop(context, {
                'name': nameController.text,
                'targetAmount': targetAmount,
                'deadline': selectedDate,
              });
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await _firestoreService.addGoal(
          name: result['name'],
          targetAmount: result['targetAmount'],
          deadline: result['deadline'],
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goal created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadGoals();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create goal: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSummaryCard() {
    if (_goals.isEmpty) return const SizedBox.shrink();

    final totalTarget = _goals.fold<double>(0, (sum, goal) => sum + goal['targetAmount']);
    final totalCurrent = _goals.fold<double>(0, (sum, goal) => sum + goal['currentAmount']);
    final totalProgress = totalCurrent / totalTarget;
    final activeGoals = _goals.where((goal) {
      final deadline = (goal['deadline'] as Timestamp).toDate();
      return deadline.isAfter(DateTime.now());
    }).length;

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
                Text(
                  'Goals Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$activeGoals Active',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(totalProgress * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Saved',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(
                          locale: 'id_ID',
                          symbol: 'Rp',
                          decimalDigits: 0,
                        ).format(totalCurrent),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal) {
    final progress = goal['currentAmount'] / goal['targetAmount'];
    final deadline = (goal['deadline'] as Timestamp).toDate();
    final daysLeft = deadline.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final isNearDeadline = daysLeft >= 0 && daysLeft < 7;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          // Show goal details dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(goal['name']),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(goal['targetAmount'])}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(goal['currentAmount'])}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Deadline: ${DateFormat('MMM d, yyyy').format(deadline)}',
                    style: TextStyle(
                      color: isOverdue ? Colors.red : (isNearDeadline ? Colors.orange : null),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(int.parse(goal['color']?.toString().replaceAll('#', '0xFF') ?? '0xFF2196F3')).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      IconData(
                        int.parse(goal['icon']?.toString().replaceAll('savings', '0xe587') ?? '0xe587', radix: 16),
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Color(int.parse(goal['color']?.toString().replaceAll('#', '0xFF') ?? '0xFF2196F3')),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(goal['currentAmount']) +
                          ' / ' +
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp',
                            decimalDigits: 0,
                          ).format(goal['targetAmount']),
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? Colors.red.withOpacity(0.1)
                          : isNearDeadline
                              ? Colors.orange.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isOverdue
                          ? 'Overdue'
                          : isNearDeadline
                              ? '$daysLeft days left'
                              : '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: isOverdue
                            ? Colors.red
                            : isNearDeadline
                                ? Colors.orange
                                : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(int.parse(goal['color']?.toString().replaceAll('#', '0xFF') ?? '0xFF2196F3')),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  Positioned(
                    right: 0,
                    top: -4,
                    child: IconButton(
                      icon: const Icon(Icons.add_circle),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () {
                        final amountController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Add to ${goal['name']}'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: amountController,
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    hintText: 'Enter amount to contribute',
                                    prefixText: 'Rp ',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Remaining: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(goal['targetAmount'] - goal['currentAmount'])}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  final amount = double.tryParse(amountController.text);
                                  if (amount == null || amount <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid amount'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pop(context, amount);
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          ),
                        ).then((amount) {
                          if (amount != null) {
                            _addToGoal(goal['id'], amount);
                          }
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
            onPressed: _isLoading ? null : _createGoal,
            tooltip: 'Add Goal',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadGoals,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _goals.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.savings,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No goals yet',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a goal to start saving',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: _createGoal,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Goal'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadGoals,
                      child: ListView(
                        children: [
                          _buildSummaryCard(),
                          ..._goals.map((goal) => _buildGoalCard(goal)).toList(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
      floatingActionButton: _goals.isNotEmpty
          ? FloatingActionButton(
              onPressed: _createGoal,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
} 