class Goal {
  final String id;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final bool isCompleted;
  final String? category;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.isCompleted,
    this.category,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      targetDate: DateTime.parse(map['targetDate'] as String),
      isCompleted: map['isCompleted'] as bool,
      category: map['category'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Goal copyWith({
    String? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    bool? isCompleted,
    String? category,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 