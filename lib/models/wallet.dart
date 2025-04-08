class Wallet {
  final String id;
  final String name;
  final double balance;
  final String currency;
  final bool isDefault;
  final String? icon;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Wallet({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.isDefault,
    this.icon,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Wallet.fromMap(Map<String, dynamic> map) {
    return Wallet(
      id: map['id'] as String,
      name: map['name'] as String,
      balance: (map['balance'] as num).toDouble(),
      currency: map['currency'] as String,
      isDefault: map['isDefault'] as bool,
      icon: map['icon'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'currency': currency,
      'isDefault': isDefault,
      'icon': icon,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Wallet copyWith({
    String? id,
    String? name,
    double? balance,
    String? currency,
    bool? isDefault,
    String? icon,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 