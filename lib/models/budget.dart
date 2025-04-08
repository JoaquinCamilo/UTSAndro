class Budget {
  final String id;
  final String category;
  final double amount;
  final double spent;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.spent,
    required this.startDate,
    required this.endDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      spent: (map['spent'] as num).toDouble(),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'amount': amount,
      'spent': spent,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Budget copyWith({
    String? id,
    String? category,
    double? amount,
    double? spent,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 