class User {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final String? address;
  final String? currency;
  final String? language;
  final bool isDarkMode;
  final List<String> walletIds;
  final List<String> categoryIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.address,
    this.currency,
    this.language,
    required this.isDarkMode,
    required this.walletIds,
    required this.categoryIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      address: map['address'] as String?,
      currency: map['currency'] as String?,
      language: map['language'] as String?,
      isDarkMode: map['isDarkMode'] as bool,
      walletIds: List<String>.from(map['walletIds'] as List),
      categoryIds: List<String>.from(map['categoryIds'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'currency': currency,
      'language': language,
      'isDarkMode': isDarkMode,
      'walletIds': walletIds,
      'categoryIds': categoryIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    String? currency,
    String? language,
    bool? isDarkMode,
    List<String>? walletIds,
    List<String>? categoryIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      walletIds: walletIds ?? this.walletIds,
      categoryIds: categoryIds ?? this.categoryIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 