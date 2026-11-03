import 'package:crpadel_mobile/features/auth/domain/app_user.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legge ruolo e permessi amministrativi dal login', () {
    final user = AppUser.fromJson({
      'id': 'admin-1',
      'email': 'admin@crpadel.it',
      'full_name': 'Mario Admin',
      'role': 'admin',
      'admin_menu_permissions': ['matches', 'bookings'],
    });

    expect(user.isAdmin, isTrue);
    expect(user.canAccessAdminMenu('matches'), isTrue);
    expect(user.canAccessAdminMenu('players'), isFalse);
  });

  test('il super admin accede a tutti i moduli', () {
    const user = AppUser(
      id: 'super-1',
      email: 'super@crpadel.it',
      fullName: 'Super Admin',
      role: 'super_admin',
    );

    expect(user.isSuperAdmin, isTrue);
    expect(user.canAccessAdminMenu('qualunque-modulo'), isTrue);
  });
}
