class SplitBill {
  final String id;
  final String title;
  final double totalAmount;
  final double yourShare;
  final DateTime date;
  final int participants;
  final bool isPaid;
  final String notes;
  final List<String> participantIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SplitBill({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.yourShare,
    required this.date,
    required this.participants,
    required this.isPaid,
    required this.notes,
    required this.participantIds,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SplitBill.fromMap(Map<String, dynamic> map) {
    return SplitBill(
      id: map['id'] as String,
      title: map['title'] as String,
      totalAmount: (map['totalAmount'] as num).toDouble(),
      yourShare: (map['yourShare'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      participants: map['participants'] as int,
      isPaid: map['isPaid'] as bool,
      notes: map['notes'] as String,
      participantIds: List<String>.from(map['participantIds'] as List),
      createdBy: map['createdBy'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'yourShare': yourShare,
      'date': date.toIso8601String(),
      'participants': participants,
      'isPaid': isPaid,
      'notes': notes,
      'participantIds': participantIds,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SplitBill copyWith({
    String? id,
    String? title,
    double? totalAmount,
    double? yourShare,
    DateTime? date,
    int? participants,
    bool? isPaid,
    String? notes,
    List<String>? participantIds,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SplitBill(
      id: id ?? this.id,
      title: title ?? this.title,
      totalAmount: totalAmount ?? this.totalAmount,
      yourShare: yourShare ?? this.yourShare,
      date: date ?? this.date,
      participants: participants ?? this.participants,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      participantIds: participantIds ?? this.participantIds,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 