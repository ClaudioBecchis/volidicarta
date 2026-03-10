class User {
  final String id; // UUID Supabase
  final String username;
  final String email;
  final bool isAdmin;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.isAdmin = false,
  });
}
