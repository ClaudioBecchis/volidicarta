class User {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;
  final String createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'password_hash': passwordHash,
        'created_at': createdAt,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        username: map['username'],
        email: map['email'],
        passwordHash: map['password_hash'],
        createdAt: map['created_at'],
      );
}
