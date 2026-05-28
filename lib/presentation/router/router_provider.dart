import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../providers/bootstrap_provider.dart';
import '../providers/core_providers.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/lapins/lapin_detail_screen.dart';
import '../screens/lapins/lapin_form_screen.dart';
import '../screens/lapins/lapin_list_screen.dart';
import '../screens/main_shell_screen.dart';
import '../screens/portees/portee_detail_screen.dart';
import '../screens/portees/portee_list_screen.dart';
import '../screens/portees/saillie_form_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/aliments/aliments_screen.dart';
import '../screens/ia/ia_screen.dart';
import '../screens/plus/plus_screen.dart';
import '../screens/alertes/alertes_screen.dart';
import '../screens/settings/settings_screen.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardNavigatorKey = GlobalKey<NavigatorState>();
final _lapinsNavigatorKey = GlobalKey<NavigatorState>();
final _porteesNavigatorKey = GlobalKey<NavigatorState>();
final _iaNavigatorKey = GlobalKey<NavigatorState>();
final _plusNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final onboardingDone = ref.watch(onboardingDoneProvider).asData?.value ?? false;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthenticated = supabase.auth.currentUser != null;
      final isSplash = location == '/splash';
      final isAuthRoute = location == '/welcome' || location == '/login';

      if (!isAuthenticated) {
        if (isAuthRoute || isSplash) return null;
        return '/welcome';
      }

      if (!onboardingDone && location != '/onboarding' && !isSplash) {
        return '/onboarding';
      }

      if (isAuthenticated &&
          onboardingDone &&
          (isAuthRoute || location == '/onboarding' || isSplash)) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/lapin/new',
        builder: (context, state) => const LapinFormScreen(),
      ),
      GoRoute(
        path: '/lapin/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LapinFormScreen(lapinId: id);
        },
      ),
      GoRoute(
        path: '/saillie/new',
        builder: (context, state) {
          final mereId = state.uri.queryParameters['mereId'];
          return SaillieFormScreen(mereId: mereId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _lapinsNavigatorKey,
            routes: [
              GoRoute(
                path: '/lapins',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: LapinListScreen(),
                ),
              ),
              GoRoute(
                path: '/lapin/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return LapinDetailScreen(lapinId: id);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _porteesNavigatorKey,
            routes: [
              GoRoute(
                path: '/portees',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PorteeListScreen(),
                ),
              ),
              GoRoute(
                path: '/portee/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PorteeDetailScreen(porteeId: id);
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _iaNavigatorKey,
            routes: [
              GoRoute(
                path: '/ia',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: IAScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _plusNavigatorKey,
            routes: [
              GoRoute(
                path: '/plus',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlusScreen(),
                ),
              ),
              GoRoute(
                path: '/alertes',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AlertesScreen(),
                ),
              ),
              GoRoute(
                path: '/aliments',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AlimentsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
