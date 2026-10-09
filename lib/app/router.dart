import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/current_club.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/bookings/presentation/book_screen.dart';
import '../features/bookings/presentation/complete_booking_controller.dart';
import '../features/bookings/presentation/complete_booking_screen.dart';
import '../features/bookings/presentation/free_courts_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/matches/presentation/match_detail_screen.dart';
import '../features/matches/presentation/matches_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'app_shell.dart';
import 'choose_club_screen.dart';
import 'routes.dart';
import 'splash_screen.dart';

/// Navigator principale, sopra la barra in basso (pagine modali).
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);
  ref.listen(currentClubProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppPaths.splash,
    refreshListenable: refresh,
    redirect: (context, state) => appRedirect(
      location: state.matchedLocation,
      club: ref.read(currentClubProvider),
      auth: ref.read(authControllerProvider),
    ),
    routes: [
      GoRoute(
        path: AppPaths.splash,
        name: AppRoutes.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: AppPaths.chooseClub,
        name: AppRoutes.chooseClub,
        builder: (_, _) => const ChooseClubScreen(),
      ),
      GoRoute(
        path: AppPaths.login,
        name: AppRoutes.login,
        builder: (_, _) => const LoginScreen(),
        routes: [
          GoRoute(
            path: AppPaths.register,
            name: AppRoutes.register,
            builder: (_, _) => const RegisterScreen(),
          ),
          GoRoute(
            path: AppPaths.forgotPassword,
            name: AppRoutes.forgotPassword,
            builder: (_, _) => const ForgotPasswordScreen(),
          ),
        ],
      ),
      // Sopra la barra in basso: si apre da Home e da Partite.
      GoRoute(
        path: AppPaths.matchDetail,
        name: AppRoutes.matchDetail,
        builder: (_, state) =>
            MatchDetailScreen(matchId: state.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          _branch(AppPaths.home, AppRoutes.home, const HomeScreen()),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.book,
                name: AppRoutes.book,
                builder: (_, _) => const BookScreen(),
                routes: [
                  GoRoute(
                    path: AppPaths.freeCourts,
                    name: AppRoutes.freeCourts,
                    builder: (_, _) => const FreeCourtsScreen(),
                  ),
                  GoRoute(
                    path: AppPaths.completeBooking,
                    name: AppRoutes.completeBooking,
                    parentNavigatorKey: rootNavigatorKey,
                    // Senza uno spazio scelto non c'è nulla da completare.
                    redirect: (_, state) =>
                        state.extra is BookingSlot ? null : AppPaths.book,
                    pageBuilder: (_, state) => MaterialPage(
                      fullscreenDialog: true,
                      child: CompleteBookingScreen(
                        slot: state.extra! as BookingSlot,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _branch(AppPaths.matches, AppRoutes.matches, const MatchesScreen()),
          _branch(AppPaths.profile, AppRoutes.profile, const ProfileScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

StatefulShellBranch _branch(String path, String name, Widget screen) =>
    StatefulShellBranch(
      routes: [GoRoute(path: path, name: name, builder: (_, _) => screen)],
    );

/// Decide dove portare l'utente: prima il circolo, poi l'accesso.
@visibleForTesting
String? appRedirect({
  required String location,
  required String? club,
  required AsyncValue<Object?> auth,
}) {
  if (club == null) {
    return location == AppPaths.chooseClub ? null : AppPaths.chooseClub;
  }
  final isPublic = AppPaths.isPublic(location);
  if (auth.isLoading) {
    // Durante il login restiamo sul form; all'avvio mostriamo lo splash.
    if (isPublic || location == AppPaths.splash) return null;
    return AppPaths.splash;
  }
  final loggedIn = auth.hasValue && auth.value != null;
  if (!loggedIn) return isPublic ? null : AppPaths.login;
  if (isPublic ||
      location == AppPaths.splash ||
      location == AppPaths.chooseClub) {
    return AppPaths.home;
  }
  return null;
}
