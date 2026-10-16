class User {
  const User({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User copyWith({
    int? id,
    String? fullName,
    String? email,
    String? passwordHash,
    String? passwordSalt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
      'passwordSalt': passwordSalt,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      passwordHash: map['passwordHash'] as String? ?? '',
      passwordSalt: map['passwordSalt'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updatedAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() => 'User(id: $id, fullName: $fullName, email: $email)';
}
