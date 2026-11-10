import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/current_club.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/domain/app_user.dart';
import '../features/admin/data/admin_repository.dart';
import '../features/admin/presentation/admin_player_detail_screen.dart';
import '../features/admin/presentation/admin_screens.dart';
import '../features/admin/presentation/admin_additional_screens.dart';
import '../features/admin/presentation/admin_create_match_screen.dart';
import '../features/bookings/presentation/book_screen.dart';
import '../features/bookings/presentation/complete_booking_controller.dart';
import '../features/bookings/presentation/complete_booking_screen.dart';
import '../features/bookings/presentation/free_courts_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/explore/presentation/club_info_screen.dart';
import '../features/explore/presentation/crpadel_tv_screen.dart';
import '../features/explore/presentation/explore_menu_screen.dart';
import '../features/explore/presentation/gallery_screen.dart';
import '../features/explore/presentation/lessons_screen.dart';
import '../features/explore/presentation/rankings_screen.dart';
import '../features/explore/presentation/tournaments_screen.dart';
import '../features/matches/presentation/match_detail_screen.dart';
import '../features/matches/presentation/matches_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/profile/presentation/settings_screen.dart';
import '../features/subscriptions/presentation/subscription_detail_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
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
      GoRoute(
        path: AppPaths.subscriptionDetail,
        name: AppRoutes.subscriptionDetail,
        builder: (_, state) => SubscriptionDetailScreen(
          subscriptionId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppPaths.notifications,
        name: AppRoutes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppPaths.exploreMenu,
        name: AppRoutes.exploreMenu,
        builder: (_, _) => const ExploreMenuScreen(),
      ),
      GoRoute(
        path: AppPaths.tournaments,
        name: AppRoutes.tournaments,
        builder: (_, _) => const TournamentsScreen(),
      ),
      GoRoute(
        path: AppPaths.rankings,
        name: AppRoutes.rankings,
        builder: (_, _) => const RankingsScreen(),
      ),
      GoRoute(
        path: AppPaths.lessons,
        name: AppRoutes.lessons,
        builder: (_, _) => const LessonsScreen(),
      ),
      GoRoute(
        path: AppPaths.gallery,
        name: AppRoutes.gallery,
        builder: (_, _) => const GalleryScreen(),
      ),
      GoRoute(
        path: AppPaths.crpadelTv,
        name: AppRoutes.crpadelTv,
        builder: (_, _) => const CrpadelTvScreen(),
      ),
      GoRoute(
        path: AppPaths.clubInfo,
        name: AppRoutes.clubInfo,
        builder: (_, _) => const ClubInfoScreen(),
      ),
      GoRoute(
        path: AppPaths.admin,
        name: AppRoutes.admin,
        builder: (_, _) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: AppPaths.adminMatches,
        name: AppRoutes.adminMatches,
        builder: (_, _) => const AdminMatchesScreen(),
      ),
      GoRoute(
        path: AppPaths.adminCreateMatch,
        name: AppRoutes.adminCreateMatch,
        builder: (_, _) => const AdminCreateMatchScreen(),
        routes: [
          GoRoute(
            path: AppPaths.adminCompleteMatch,
            name: AppRoutes.adminCompleteMatch,
            redirect: (_, state) =>
                state.extra is BookingSlot ? null : AppPaths.adminMatches,
            pageBuilder: (_, state) => MaterialPage(
              fullscreenDialog: true,
              child: CompleteBookingScreen(
                slot: state.extra! as BookingSlot,
                successRouteName: AppRoutes.adminMatches,
              ),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppPaths.adminBookings,
        name: AppRoutes.adminBookings,
        builder: (_, _) => const AdminBookingsScreen(),
      ),
      GoRoute(
        path: AppPaths.adminPlayers,
        name: AppRoutes.adminPlayers,
        builder: (_, _) => const AdminPlayersScreen(),
        routes: [
          GoRoute(
            path: ':id',
            name: AppRoutes.adminPlayerDetail,
            builder: (_, state) => AdminPlayerDetailScreen(
              playerId: state.pathParameters['id']!,
              player: state.extra is AdminPlayer
                  ? state.extra as AdminPlayer
                  : null,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppPaths.adminCommunications,
        name: AppRoutes.adminCommunications,
        builder: (_, _) => const AdminCommunicationsScreen(),
      ),
      GoRoute(
        path: AppPaths.adminMatchHistory,
        name: AppRoutes.adminMatchHistory,
        builder: (_, _) => const AdminMatchHistoryScreen(),
      ),
      GoRoute(
        path: AppPaths.adminUsers,
        name: AppRoutes.adminUsers,
        builder: (_, _) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppPaths.adminStatistics,
        name: AppRoutes.adminStatistics,
        builder: (_, _) => const AdminStatisticsScreen(),
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
                builder: (_, state) => BookScreen(
                  createMatch: state.uri.queryParameters['mode'] == 'match',
                  createLesson: state.uri.queryParameters['mode'] == 'lesson',
                ),
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppPaths.profile,
                name: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: AppPaths.settings,
                    name: AppRoutes.settings,
                    builder: (_, _) => const SettingsScreen(),
                    routes: [
                      GoRoute(
                        path: AppPaths.changePassword,
                        name: AppRoutes.changePassword,
                        builder: (_, _) => const ChangePasswordScreen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
  final user = auth.value;
  if (location.startsWith(AppPaths.admin) &&
      (user is! AppUser || !user.isAdmin)) {
    return AppPaths.home;
  }
  if (user is AppUser && location.startsWith(AppPaths.admin)) {
    final requiredMenu = switch (location) {
      final value when value.startsWith(AppPaths.adminMatchHistory) =>
        'matches',
      final value when value.startsWith(AppPaths.adminMatches) => 'matches',
      final value when value.startsWith(AppPaths.adminBookings) => 'bookings',
      final value when value.startsWith(AppPaths.adminPlayers) => 'players',
      final value when value.startsWith(AppPaths.adminUsers) => 'users',
      final value when value.startsWith(AppPaths.adminStatistics) =>
        'statistics',
      final value when value.startsWith(AppPaths.adminCommunications) =>
        'push_notifications',
      _ => null,
    };
    if (requiredMenu != null && !user.canAccessAdminMenu(requiredMenu)) {
      return AppPaths.admin;
    }
  }
  if (isPublic ||
      location == AppPaths.splash ||
      location == AppPaths.chooseClub) {
    return AppPaths.home;
  }
  return null;
}
