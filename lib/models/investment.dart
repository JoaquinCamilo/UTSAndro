class Investment {
  final String id;
  final String name;
  final String type; // e.g., 'stock', 'bond', 'mutual_fund', 'crypto'
  final double amount;
  final double currentValue;
  final DateTime purchaseDate;
  final String? symbol;
  final double? quantity;
  final double? purchasePrice;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Investment({
    required this.id,
    required this.name,
    required this.type,
    required this.amount,
    required this.currentValue,
    required this.purchaseDate,
    this.symbol,
    this.quantity,
    this.purchasePrice,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map['id'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      currentValue: (map['currentValue'] as num).toDouble(),
      purchaseDate: DateTime.parse(map['purchaseDate'] as String),
      symbol: map['symbol'] as String?,
      quantity: map['quantity'] as double?,
      purchasePrice: map['purchasePrice'] as double?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'amount': amount,
      'currentValue': currentValue,
      'purchaseDate': purchaseDate.toIso8601String(),
      'symbol': symbol,
      'quantity': quantity,
      'purchasePrice': purchasePrice,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Investment copyWith({
    String? id,
    String? name,
    String? type,
    double? amount,
    double? currentValue,
    DateTime? purchaseDate,
    String? symbol,
    double? quantity,
    double? purchasePrice,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currentValue: currentValue ?? this.currentValue,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 