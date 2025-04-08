class Bill {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bill.fromMap(Map<String, dynamic> map) {
    return Bill(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate'] as String),
      isPaid: map['isPaid'] as bool,
      notes: map['notes'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isPaid': isPaid,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Bill copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 