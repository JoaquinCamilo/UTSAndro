class Debt {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final bool isLender;
  final String notes;
  final String contactName;
  final String contactPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Debt({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.isPaid,
    required this.isLender,
    required this.notes,
    required this.contactName,
    required this.contactPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  double get remainingAmount => isPaid ? 0 : amount;

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: DateTime.parse(map['dueDate'] as String),
      isPaid: map['isPaid'] as bool,
      isLender: map['isLender'] as bool,
      notes: map['notes'] as String,
      contactName: map['contactName'] as String,
      contactPhone: map['contactPhone'] as String,
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
      'isLender': isLender,
      'notes': notes,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Debt copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    bool? isLender,
    String? notes,
    String? contactName,
    String? contactPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Debt(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      isLender: isLender ?? this.isLender,
      notes: notes ?? this.notes,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 