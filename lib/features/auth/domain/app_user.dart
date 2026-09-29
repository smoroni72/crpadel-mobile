class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.emailVerified,
    this.clubRole,
  });

  final String id;
  final String email;
  final String fullName;
  final bool emailVerified;
  final String? clubRole;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    emailVerified: json['email_verified'] as bool? ?? false,
    clubRole: json['club_role'] as String?,
  );
}
