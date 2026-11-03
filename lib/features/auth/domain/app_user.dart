/// Utente autenticato restituito da `/auth/me` e `/auth/login`.
/// Ruolo e permessi sono disponibili subito al router per proteggere l'area
/// amministrativa anche quando si apre un collegamento diretto.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.emailVerified = false,
    this.clubRole,
    this.role = 'user',
    this.adminMenuPermissions = const [],
  });

  final String id;
  final String email;
  final String fullName;
  final bool emailVerified;
  final String? clubRole;
  final String role;
  final List<String> adminMenuPermissions;

  bool get isSuperAdmin => role == 'super_admin';
  bool get isAdmin => isSuperAdmin || role == 'admin';

  bool canAccessAdminMenu(String key) =>
      isSuperAdmin || (isAdmin && adminMenuPermissions.contains(key));

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as String,
    email: json['email'] as String,
    fullName: json['full_name'] as String,
    emailVerified: json['email_verified'] as bool? ?? false,
    clubRole: json['club_role'] as String?,
    role: json['role'] as String? ?? 'user',
    adminMenuPermissions:
        (json['admin_menu_permissions'] as List<dynamic>? ?? const [])
            .map((value) => value.toString())
            .toList(growable: false),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'full_name': fullName,
    'email_verified': emailVerified,
    'club_role': clubRole,
    'role': role,
    'admin_menu_permissions': adminMenuPermissions,
  };
}
